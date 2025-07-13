from jinja2 import Environment, FileSystemLoader

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
    print("\nPlease select an availability Zone (a, b, c):")
    while True:
        az= input("\n").lower()
        if az in VALID_AZ:
            break
        else:
            print("Invalid choise, please enter a valid zone (a, b, c).")

    # Step 4: Load Balancer Name
    alb_name = input("\nEnter a name for your Load Balancer: ").strip()

    # Print summary
    print("\nDeployment Configuration:")
    print(f"AMI ID: {ami_id}")
    print(f"Instance Type: {instance_type}")
    print(f"Region: {region}")
    print(f"Availability Zone: {az}")
    print(f"Load Balancer Name: {alb_name}")

    return {
        "ami_id": ami_id,
        "instance_type": instance_type,
        "region": region,
        "availability_zone": az,
        "alb_name": alb_name
    }

def Load_template(config): #Pass the variable into a jinja2 template
    env = Environment(loader=FileSystemLoader("./source")) 
    template = env.get_template("template.txt.j2")
    output = template.render(config)
    with open("vars.txt", "w") as file:
        file.write(output)
    print("\nTemplate rendered and saved to vars.txt")


# Run the script
if __name__ == "__main__":
    config = get_user_input()
    Load_template(config)
    print("\nDeployment configuration completed successfully.")