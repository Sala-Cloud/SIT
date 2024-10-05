pipeline {
    agent any

    environment {
        // Path to inventory file
        INVENTORY_PATH = "configs/${params.ENVIRONMENT}_inventory.ini"
    }

    stages {
        stage('Get Hosts from Inventory') {
            steps {
                script {
                    // Parse the inventory file to get the list of hosts (for simplicity, using grep)
                    def hostList = sh(
                        script: "grep -E '^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+' ${INVENTORY_PATH}",
                        returnStdout: true
                    ).trim().split('\n')
                    
                    // Save the host list as choices for the HOST_FILTER parameter
                    def hostChoices = hostList.join("\n")
                    currentBuild.description = "Hosts: \n${hostChoices}" // For debugging
                    
                    // Dynamically create input parameters for host selection
                    properties([
                        parameters([
                            choice(name: 'HOST_FILTER', choices: hostList, description: 'Choose a specific hostname or IP address to deploy')
                        ])
                    ])
                }
            }
        }

        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/Sala-Cloud/SIT.git'
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                script {
                    // Determine the inventory file based on the selected environment
                    def inventoryFile = "configs/${params.ENVIRONMENT}_inventory.ini"

                    // Map friendly playbook names to actual file names
                    def playbookMap = [
                        'password-policy': 'password-policy_playbook.yml',
                        'install-docker': 'install-docker_playbook.yml',
                        'remove-kasperskyagent': 'remove-kasperskyagent_playbook.yml'
                    ]

                    // Get the actual playbook file name based on the selected friendly name
                    def playbookFile = playbookMap[params.PLAYBOOK]

                    // Run the selected Ansible playbook with the chosen inventory and host filter
                    sh """
                    ansible-playbook -i ${inventoryFile} --limit ${params.HOST_FILTER} Playbook/${playbookFile}
                    """
                }
            }
        }
    }
}
