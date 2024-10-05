pipeline {
    agent any

    environment {
        // Path to inventory file (based on selected environment)
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
                // Clone your GitHub repository
                git branch: 'main', url: 'https://github.com/Sala-Cloud/SIT.git'
            }
        }

        stage('Get Hosts from Inventory') {
            steps {
                script {
                    // Extract IP addresses or hostnames from the inventory file
                    def hostList = sh(
                        script: "grep -E '^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+' ${INVENTORY_PATH}",
                        returnStdout: true
                    ).trim().split('\n')

                    // Create a list of host options for the HOST_FILTER parameter
                    def hostChoices = hostList.join("\n")
                    currentBuild.description = "Hosts: \n${hostChoices}"  // Display hosts in the build description for debugging

                    // Dynamically update the Jenkins parameters to add the host selection
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
                    // Map playbook names to actual file names
                    def playbookMap = [
                        'password-policy': 'password-policy_playbook.yml',
                        'install-docker': 'install-docker_playbook.yml',
                        'remove-kasperskyagent': 'remove-kasperskyagent_playbook.yml'
                    ]

                    // Get the actual playbook file based on the chosen friendly name
                    def playbookFile = playbookMap[params.PLAYBOOK]

                    // Run the Ansible playbook with the chosen inventory, playbook, and host filter
                    sh """
                    ansible-playbook -i ${INVENTORY_PATH} --limit ${params.HOST_FILTER} Playbook/${playbookFile}
                    """
                }
            }
        }
    }
}
