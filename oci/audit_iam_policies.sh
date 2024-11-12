#!/bin/bash

# Function to list IAM policies for a compartment
list_compartment_iam_policies() {
    local compartment_id=$1
    oci iam policy list --compartment-id "$compartment_id"
}

# Function: list_all_compartment_iam_policies
# Description: This function lists all IAM policies for a given compartment in Oracle Cloud Infrastructure (OCI).
# Usage: Call this function without any arguments to retrieve and display all IAM policies for the tenancy.
# Dependencies: Ensure that OCI CLI is installed and configured with the necessary permissions to list IAM policies.
list_all_compartment_iam_policies() {
    local root_compartment=$(oci iam compartment list --all --compartment-id-in-subtree true --access-level ACCESSIBLE --include-root --raw-output --query "data[?contains(\"id\",'tenancy')].id | [0]")
    
    function _list_compartments() {
        local compartment_id=$1
        compartment_name=$(oci iam compartment get --compartment-id "$compartment_id" --query "data.name" --raw-output)

        echo "Compartment: $compartment_name ($compartment_id)"

        list_compartment_iam_policies "$compartment_id"
        
        for sub_compartment_id in $(oci iam compartment list --compartment-id "$compartment_id" --all --query "data[].id" | jq -r '.[]'); do
            _list_compartments "$sub_compartment_id"
        done
    }
    
    _list_compartments "$root_compartment"
}

list_all_compartment_iam_policies
