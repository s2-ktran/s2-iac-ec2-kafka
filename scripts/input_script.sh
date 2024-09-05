#!/bin/bash

set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Script directory: $SCRIPT_DIR"

# read -p "Enter your SingleStore API Key: " TF_VAR_singlestore_api_key
# if [ -z "$TF_VAR_singlestore_api_key" ]; then
#     echo "Please set the TF_VAR_singlestore_api_key environment variable"
#     exit 1
# fi

read -p "Enter the AWS region (e.g., us-east-1): " AWS_REGION
if [[ -z "$AWS_REGION" ]]; then
  echo "Region cannot be empty."
  exit 1
fi

read -p "Enter the SingleStore endpoints (comma-separated): " SINGLE_STORE_IPS_INPUT
SINGLE_STORE_IPS_INPUT=$(echo $SINGLE_STORE_IPS_INPUT | tr -d ' ')
if [[ -z "$SINGLE_STORE_IPS_INPUT" ]]; then
  echo "You must enter at least one IP address."
  exit 1
fi

IFS=',' read -r -a IP_ARRAY <<< "$SINGLE_STORE_IPS_INPUT"
if [[ ${#IP_ARRAY[@]} -ne 4 ]]; then
  echo "Please enter exactly 4 IP addresses."
  exit 1
fi

IP_1=${IP_ARRAY[0]}
IP_2=${IP_ARRAY[1]}
IP_3=${IP_ARRAY[2]}
IP_4=${IP_ARRAY[3]}

# Export the variables
echo "These 4 IP addresses you entered are: $IP_1, $IP_2, $IP_3, $IP_4"
SINGLE_STORE_IPS="$IP_1/32,$IP_2/32,$IP_3/32,$IP_4/32"

# Convert the comma-separated IP addresses to a format acceptable by Terraform
SINGLE_STORE_IPS_LIST=$(echo $SINGLE_STORE_IPS | sed 's/,/","/g' | sed 's/^/["/' | sed 's/$/"]/')
echo $SINGLE_STORE_IPS_LIST

MY_IP=$(curl -s https://api.ipify.org)
echo "Current IP Address: $MY_IP"

export AWS_PROFILE_NAME=$(aws sts get-caller-identity --query UserId --output text | awk -F':' '{print $2}' | awk -F'@' '{print $1}')

read -p "Enter the EC2 instance type (default is t2.large): " INSTANCE_TYPE
INSTANCE_TYPE=${INSTANCE_TYPE:-t2.large}

read -p "Enter the name of the key pair you want to provision: " KEY_PAIR_NAME
if [[ -z "$KEY_PAIR_NAME" ]]; then
  echo "Key pair name cannot be empty."
  exit 1
fi

# Write the variables to the output script
cat <<EOF > $SCRIPT_DIR/output_vars.sh
#!/bin/bash
export TF_VAR_singlestore_api_key="$TF_VAR_singlestore_api_key"
export AWS_REGION="$AWS_REGION"
export IP_1="$IP_1"
export IP_2="$IP_2"
export IP_3="$IP_3"
export IP_4="$IP_4"
export SINGLE_STORE_IPS_LIST='$SINGLE_STORE_IPS_LIST'
export MY_IP="$MY_IP"
export AWS_PROFILE_NAME="$AWS_PROFILE_NAME"
export INSTANCE_TYPE="$INSTANCE_TYPE"
export KEY_PAIR_NAME="$KEY_PAIR_NAME"
EOF

echo "Variables have been saved to $SCRIPT_DIR/output_vars.sh"
