pipeline {
    agent any

    environment {
        // Define the path to the inventory file based on the selected environment
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
                // Clone the repository where the playbooks and inventory files are located
                git branch: 'main', url: 'https://github.com/Sala-Cloud/SIT.git'
            }
        }

        stage('Extract Hosts from Inventory') {
            steps {
                script {
                    // Check if the inventory file exists
                    if (!fileExists(INVENTORY_PATH)) {
                        error "Inventory file not found: ${INVENTORY_PATH}"
                    }

                    // Extract valid IPs or hostnames from the inventory file
                    def hostList = sh(
                        script: """
                        grep -E '^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+|^[a-zA-Z]+' ${INVENTORY_PATH} | grep -v '^#' || true
                        """,
                        returnStdout: true
                    ).trim().split('\n')

                    // Validate if any hosts were found
                    if (hostList.size() == 0) {
                        error "No valid hosts found in ${INVENTORY_PATH}. Please ensure the inventory file contains valid host entries."
                    }

                    // Dynamically present the hosts as a selection choice
                    def selectedHost = input message: 'Select a host to deploy', parameters: [
                        choice(name: 'HOST_FILTER', choices: hostList, description: 'Select a host to deploy')
                    ]
                    
                    // Save the selected host for further use
                    env.SELECTED_HOST = selectedHost
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                script {
                    // Define the mapping between friendly playbook names and actual file names
                    def playbookMap = [
                        'password-policy': 'password-policy_playbook.yml',
                        'install-docker': 'install-docker_playbook.yml',
                        'remove-kasperskyagent': 'remove-kasperskyagent_playbook.yml'
                    ]

                    // Get the actual playbook file name based on the chosen friendly name
                    def playbookFile = playbookMap[params.PLAYBOOK]

                    if (!playbookFile) {
                        error "Playbook not found for selection: ${params.PLAYBOOK}"
                    }

                    // Check if the playbook exists
                    if (!fileExists("Playbook/${playbookFile}")) {
                        error "Playbook file not found: Playbook/${playbookFile}"
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
