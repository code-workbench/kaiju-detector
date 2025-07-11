# Kaiju Detector Infrastructure

This directory contains Terraform configuration to deploy a private Azure Kubernetes Service (AKS) cluster for the Kaiju Detector application.

## Architecture

The infrastructure creates:
- **Resource Group**: Container for all resources
- **Virtual Network**: Private network with CIDR 10.0.0.0/16
- **AKS Subnet**: Dedicated subnet for AKS nodes (10.0.1.0/24)
- **Services Subnet**: Additional subnet for other services (10.0.2.0/24)
- **Private AKS Cluster**: Kubernetes cluster without public endpoint
- **Log Analytics Workspace**: For monitoring and logging

## Features

- **Private Cluster**: AKS API server is not accessible from the internet
- **Auto-scaling**: Node pool can scale from 1 to 5 nodes
- **Network Security**: Nodes have no public IPs
- **Monitoring**: Integrated with Azure Monitor and Log Analytics

## Prerequisites

1. **Azure CLI**: Install and authenticate
   ```bash
   az login
   az account set --subscription "<your-subscription-id>"
   ```

2. **Terraform**: Install Terraform (use winget on Windows)
   ```bash
   # On Linux/macOS
   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
   sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
   sudo apt-get update && sudo apt-get install terraform
   
   # On Windows with winget
   winget install HashiCorp.Terraform
   ```

## Deployment

1. **Initialize Terraform**:
   ```bash
   cd infra
   terraform init
   ```

2. **Configure Variables** (optional):
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your preferred values
   ```

3. **Validate Configuration**:
   ```bash
   terraform validate
   ```

4. **Plan Deployment**:
   ```bash
   terraform plan
   ```

5. **Deploy Infrastructure**:
   ```bash
   terraform apply -auto-approve
   ```

## Accessing the Cluster

Since this is a private cluster, you'll need to access it from within the virtual network or set up a connection:

1. **Get kubectl credentials**:
   ```bash
   az aks get-credentials --resource-group <resource-group-name> --name <aks-cluster-name>
   ```

2. **Access options**:
   - Deploy a jump box VM in the same virtual network
   - Use Azure Bastion for secure access
   - Set up VPN or ExpressRoute connection

## Configuration Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `resource_group_name` | Name of the resource group | `rg-kaiju-detector` |
| `location` | Azure region | `East US` |
| `prefix` | Prefix for resource names | `kaiju` |
| `environment` | Environment tag | `dev` |
| `node_count` | Initial number of nodes | `2` |
| `node_vm_size` | VM size for nodes | `Standard_D2s_v3` |

## Outputs

After deployment, Terraform will output:
- Resource group name
- AKS cluster name and ID
- Virtual network information
- Subnet IDs
- Log Analytics workspace ID
- Kubernetes config (sensitive)

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

## Security Considerations

- The AKS cluster has no public endpoint
- Node VMs have no public IPs
- Network traffic is isolated within the virtual network
- Log Analytics provides audit and monitoring capabilities
- System-assigned managed identity is used for AKS

## Next Steps

After deployment:
1. Configure kubectl access
2. Deploy the Kaiju Detector application
3. Set up monitoring and alerting
4. Configure backup and disaster recovery
