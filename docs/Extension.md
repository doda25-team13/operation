# Extension Proposal:
This document outlines a proposal for extending the existing system to overcome certain identified shortcomings.

## The Identified Shortcoming
The current project deployment strategy is manual and tedious. While the Helm chart centralizes the configuration, the actual application state in the cluster can differ a lot depending on the state of the local machine. We often saw issues where it only works on the developer's  machine. 

## Proposed Extension
ArgoCD is a Kubernetes controller that continuously monitors the operations repository. It compares the desired state defined in the Git repo against the actual live state in the cluster. If they differ, ArgoCD automatically syncs the cluster to match Git [1]. 


## Implementation Details
1. Install ArgoCD in the Kubernetes cluster.
2. Define the application in ArgoCD, pointing it to the Git repository (operation) containing the Helm chart and configuration files.
3. Configure the syncPolicy in ArgoCD. This enable automated pruning (deleting resources not in Git) and automated selfHeal (automatically reversing manual changes made via kubectl).

## Expected Outcomes & Verification
1. Single Source of Truth: The Git repository becomes the absolute truth. If it's not in Git, it doesn't exist in the cluster. 
2. Automated Pruning and Healing: Automatically removes resources that are no longer defined in Git and reverts any manual changes made directly in the cluster that is not in Git [3].  
3. Automatic Retry Refresh: If a deployment fails and a new fix is pushed to Git. ArgoCD will automatically pick up and try the newer version.
4. ArgoCD Dashboard: A web-based dashboard provides visibility into the application state, sync status, and a tree of application and their details. 




## Other shortcomings
### Contribution Process & Assignment design
The current project has the contribution system such that six of the team members are working on the same assignment each week. And as some assignments are more sequential rather than parallel, this means that one blocking task due to bugs, sick leave, or other unforeseen issues can hold up the entire team. This then results in some members having to wait for others to finish their work before they can proceed with their own tasks. And this effect builds up over time, leading to significant delays in the overall project timeline. This is especially the case with assignment 2. 

It often leads to more rushed work, as team members try to catch up on lost time, which can compromise the quality of the final output. This includes undocumented code/PR, insufficiently tested features and technical debt. 
  
To address this, we propose a more modular approach to task assignments. Instead of having all team members work on the same assignment, we can restructure the assignments into smaller, independent tasks that can be worked on in parallel. This way, if one task is delayed, it does not necessarily hold up the entire team. Additionally, we can implement a more flexible contribution process where team members can pick tasks based on their expertise and availability, rather than being assigned to a single task for the entire week. This will help to ensure that work continues to progress even if some tasks encounter delays.

### Before Runtime checks for yaml config files
Currently, the system crashes / does not behave correctly when there are issues with the yaml config files. This is because there are no checks to validate the config files before they are used at runtime. This increases the diffuculty of pinning down the source of the bugs / crashes. To address this, we can utilize linter for YAML like YAMLlint before any runtime execution. This linter will check for common issues such as syntax errors, missing required fields etc. 




## References
1. Argo Project. (n.d.). Argo CD - Declarative GitOps CD for Kubernetes. Retrieved from https://argo-cd.readthedocs.io/en/stable/
2. Argo Project. (n.d.). Automated Sync Policy: Pruning and Self-Healing. Argo CD Documentation. Retrieved from https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/
