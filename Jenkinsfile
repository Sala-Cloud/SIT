pipeline {
    agent any

    environment {
        // Path to the inventory file based on the environment
        INVENTORY_PATH = "configs/${params.ENVIRONMENT}_inventory.ini"
    }

    parameters {
        // Choose the environment (inventory)
        choice(name: 'ENVIRONMENT', choices: ['PROD', 'UAT', 'SIT'], description: 'Choose the environment to deploy')

        // Choose the playbook to run
        choice(name: 'PLAYBOOK', choices: ['password-policy', 'install-docker', 'remove-kasperskyagent'], description: 'Choose the playbook to deploy')
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Clone the GitHub repository where the playbooks and inventory files are stored
                git branch: 'main', url: 'https://github.com/Sala-Cloud/SIT.git'
            }
        }

        stage('Extract Hosts from Inventory') {
            steps {
                script {
                    // Extract hostnames or IP addresses from the selected inventory file
                    def hostList = sh(
                        script: "grep -E '^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+' ${INVENTORY_PATH} || grep -E '^[a-zA-Z0-9-]+' ${INVENTORY_PATH}",
                        returnStdout: true
                    ).trim().split('\n')

                    if (hostList.size() == 0) {
                        error "No valid hosts found in ${INVENTORY_PATH}"
                    }

                    // Create a list of hosts and dynamically set the HOST_FILTER parameter
                    def hostChoices = hostList.join("\n")
                    currentBuild.description = "Available Hosts: \n${hostChoices}"  // Display the hosts in the build description for debugging

                    // Update the pipeline to prompt the user to select a specific host
                    properties([
                        parameters([
                            choice(name: 'HOST_FILTER', choices: hostList, description: 'Choose a specific hostname or IP address to deploy')
                        ])
                    ])
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                script {
                    // Define a map for friendly playbook names to actual file names
                    def playbookMap = [
                        'password-policy': 'password-policy_playbook.yml',
                        'install-docker': 'install-docker_playbook.yml',
                        'remove-kasperskyagent': 'remove-kasperskyagent_playbook.yml'
                    ]

                    // Fetch the actual playbook filename based on the selected friendly name
                    def playbookFile = playbookMap[params.PLAYBOOK]

                    // Run the selected Ansible playbook using the chosen inventory and host filter
                    sh """
                    ansible-playbook -i ${INVENTORY_PATH} --limit ${params.HOST_FILTER} Playbook/${playbookFile}
                    """
                }
            }
        }
    }
}
