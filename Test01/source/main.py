from python_terraform import Terraform, IsFlagged, IsNotFlagged, TerraformCommandError
from jinja2 import Environment, FileSystemLoader
import sys
import boto3
import json

UBUNTU_AMI = "ami-0eb9d6fc9fab44d24"
AMAZON_AMI = "ami-0d1b5a8c13042c939"
VALID_AZ = ["a","b","c"]

def get_user_input():
    # Step 1: Choose AMI
    print(f"""
    Select AMI:
    1. Ubuntu ({UBUNTU_AMI})
    2. Amazon Linux ({AMAZON_AMI})
    """)
    while True:
        ami_choice = input("")
        if ami_choice == "1":
            ami_id = UBUNTU_AMI
            break
        elif ami_choice == "2":
            ami_id = AMAZON_AMI
            break
        else:
            print("invalid input, please try again.")

    # Step 2: Choose Instance Type
    print("""
    Select Instance Type:
    1. t3.small
    2. t3.medium
          """)
    while True:
        instance_choice = input("")
        if instance_choice == "1":
            instance_type = "t3.small"
            break
        elif instance_choice == "2":
            instance_type = "t3.medium"
            break
        else:
            print("Invalid input, please enter 1 or 2.")

    # Step 3: Select Region and Availability Zone
    region = input("\nEnter AWS Region (please use us-east-2): ").lower()
    if region != "us-east-2":
        print("Only us-east-2 is supported. Defaulting to us-east-2.")
        region = "us-east-2"

    #Step 3.1: Select Availability Zone
    print("\nPlease select a primary availability Zone (a, b, c):")
    while True:
        az1= input("\n").lower()
        if az1 in VALID_AZ:
            break
        else:
            print("Invalid choice, please enter a valid zone (a, b, c).")
    print("please select a secondary availability Zone (a, b, c):")
    while True:
        az2= input("\n").lower()
        if az2 not in VALID_AZ:
            print("Invalid choise, please enter a valid zone (a, b, c).")
        elif az2 == az1:
            print("You cannot select the same availability zone twice, please choose a different one.")
        else:
            azs = az1 + az2
            break
            # Step 4: Load Balancer Name
    alb_name = input("\nEnter a name for your Load Balancer: ").strip()

    # Print summary
    print("\nDeployment Configuration:")
    print(f"AMI ID: {ami_id}")
    print(f"Instance Type: {instance_type}")
    print(f"Region: {region}")
    print(f"Availability Zone: {azs}")
    print(f"Load Balancer Name: {alb_name}")

    return {
        "ami_id": ami_id,
        "instance_type": instance_type,
        "region": region,
        "availability_zone": azs,
        "alb_name": alb_name
    }

def Load_template(config): #Pass the variable into a jinja2 template
    env = Environment(loader=FileSystemLoader("./source")) 
    template = env.get_template("template.txt.j2")
    output = template.render(config)
    with open("./Terraform/main.tf", "w") as file:
        file.write(output)
    print("\nTemplate rendered and saved to main.tf")

def run_terraform():
    tf = Terraform(working_dir='./Terraform')  # assuming you run script where terraform files are

    print("\nInitializing Terraform...")
    return_code, stdout, stderr = tf.init()
    if return_code not in (0, 2):
        print("Terraform init failed:")
        print(return_code)
        print(stderr)
        sys.exit(1)
    print(stdout)

    print("\nPlanning Terraform deployment...")
    return_code, stdout, stderr = tf.plan(no_color=IsFlagged)
    if return_code not in (0, 2):
        print("Terraform plan failed:")
        print(return_code)
        print(stderr)
        sys.exit(1)
    print(stdout)

    print("\nApplying Terraform deployment...")
    return_code, stdout, stderr = tf.apply(skip_plan=True, no_color=IsFlagged, capture_output=True, auto_approve=True)
    if return_code not in (0, 2):
        print("Terraform apply failed:")
        print(return_code)
        print(stderr)
        sys.exit(1)
    print(stdout)

    # After apply, get outputs
    print("\nFetching Terraform outputs...")
    try:
        return_code, outputs, stderr = tf.output()
    except Exception as e:
        print(f"NOF Didn't get to part 1: {e}")
        sys.exit(1)
    if return_code != 0:
        print("Failed to get Terraform outputs:")
        print(return_code)
        print("NOF Didnt get to part 2: ", stderr)
        sys.exit(1)
    try: 
        print("Terraform Outputs:")
        for key, value in outputs.items():
            print(f"{key}: {value['value']}")
    except Exception as e:
        print(f"Error fetching outputs: {e}")
        print("NOF Didnt get to part 3: ", stderr)
        sys.exit(1)
    instance_id = outputs["instance_id"]["value"]
    lb_dns = outputs["lb_dns_name"]["value"]
    return instance_id, lb_dns



def validate_aws_resources(instance_id, lb_dns, region="us-east-2"):
    import boto3
    import json

    print("\nValidating AWS resources with boto3...")
    ec2 = boto3.client("ec2", region_name=region)
    elb = boto3.client("elbv2", region_name=region)

    try:
        # Get EC2 instance details
        ec2_resp = ec2.describe_instances(InstanceIds=[instance_id])
        reservations = ec2_resp["Reservations"]
        if not reservations or not reservations[0]["Instances"]:
            raise Exception("Instance not found")
        instance = reservations[0]["Instances"][0]
        instance_state = instance["State"]["Name"]
        public_ip = instance.get("PublicIpAddress", "N/A")

        # Get ALB DNS name
        lb_resp = elb.describe_load_balancers()
        lb_dns_found = next((lb["DNSName"] for lb in lb_resp["LoadBalancers"] if lb["DNSName"] == lb_dns), None)

        if not lb_dns_found:
            raise Exception("Load balancer not found")

        # Save to JSON
        validation_data = {
            "instance_id": instance_id,
            "instance_state": instance_state,
            "public_ip": public_ip,
            "load_balancer_dns": lb_dns_found
        }
        with open("aws_validation.json", "w") as f:
            json.dump(validation_data, f, indent=4)
        print("✅ AWS validation successful. Data saved to aws_validation.json.")

    except Exception as e:
        print(f"❌ AWS Validation failed: {e}")
        sys.exit(1)


# Run the script
if __name__ == "__main__":
    config = get_user_input()
    Load_template(config)
    print("\nDeployment configuration completed successfully.")

    instance_id, lb_dns = run_terraform()

    print("\nTerraform deployment completed successfully.")

    # Validate AWS resources
    validate_aws_resources(instance_id, lb_dns, region=config["region"])