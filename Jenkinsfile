pipeline {
    agent any

    parameters {
        // Choose the environment (inventory)
        choice(name: 'ENVIRONMENT', choices: ['PROD', 'UAT', 'SIT'], description: 'Choose the environment to deploy')

        // Choose the playbook to run
        choice(name: 'PLAYBOOK', choices: ['password-policy', 'install-docker', 'remove-kasperskyagent'], description: 'Choose the playbook to deploy')
    }

    environment {
        // Path to inventory file based on the selected environment
        INVENTORY_PATH = "configs/${params.ENVIRONMENT}_inventory.ini"
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Clone the repository where the playbooks and inventory files are located
                git branch: 'main', url: 'https://github.com/Sala-Cloud/SIT.git'
            }
        }

        stage('Get Hosts from Inventory') {
            steps {
                script {
                    // Check if the inventory file exists
                    if (!fileExists(INVENTORY_PATH)) {
                        error "Inventory file not found: ${INVENTORY_PATH}"
                    }

                    // Extract valid IPs or hostnames from the inventory file
                    def hostList = sh(
                        script: "grep -E '^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+|^[a-zA-Z]+' ${INVENTORY_PATH} | grep -v '^#' || true",
                        returnStdout: true
                    ).trim().split('\n')

                    // Check if any hosts were found
                    if (hostList.size() == 0) {
                        error "No valid hosts found in ${INVENTORY_PATH}. Please ensure the inventory file contains valid host entries."
                    }

                    // Set the host choices for user input
                    def hostChoices = hostList.collect { it.trim() } // Trim whitespace from each host
                    def selectedHost = input message: 'Select a host to deploy', parameters: [
                        choice(name: 'HOST_FILTER', choices: hostChoices, description: 'Select a host to deploy')
                    ]

                    // Save the selected host for later use
                    env.SELECTED_HOST = selectedHost
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                script {
                    // Define a mapping of friendly playbook names to their file paths
                    def playbookMap = [
                        'password-policy': 'password-policy_playbook.yml',
                        'install-docker': 'install-docker_playbook.yml',
                        'remove-kasperskyagent': 'remove-kasperskyagent_playbook.yml'
                    ]

                    // Determine the actual playbook file based on the selected friendly name
                    def playbookFile = playbookMap[params.PLAYBOOK]

                    if (!playbookFile) {
                        error "Playbook not found for selection: ${params.PLAYBOOK}"
                    }

                    // Run the Ansible playbook with the selected host filter
                    sh """
                    ansible-playbook -i ${INVENTORY_PATH} --limit ${env.SELECTED_HOST} Playbook/${playbookFile}
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Job finished with status: ${currentBuild.currentResult}"
        }
        failure {
            echo "Build failed! Please check the logs for errors."
        }
    }
}
