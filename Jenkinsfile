pipeline {
    agent any

    environment {
        // Path to inventory file based on the environment
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
                // Clone the repository where the playbooks and inventory files are stored
                git branch: 'main', url: 'https://github.com/Sala-Cloud/SIT.git'
            }
        }

        stage('Extract Hosts from Inventory') {
            steps {
                script {
                    // Extract hostnames or IPs from the selected inventory file
                    def hostList = sh(
                        script: "grep -E '^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+' ${INVENTORY_PATH} || grep -E '^[a-zA-Z0-9-]+' ${INVENTORY_PATH}",
                        returnStdout: true
                    ).trim().split('\n')

                    if (hostList.size() == 0) {
                        error "No valid hosts found in ${INVENTORY_PATH}"
                    }

                    // Show the available hosts as part of the input prompt
                    def selectedHost = input message: 'Select a host to deploy', parameters: [
                        choice(name: 'HOST_FILTER', choices: hostList, description: 'Select a host to deploy')
                    ]
                    
                    // Save selected host to the environment
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

                    // Run the Ansible playbook with the selected host filter
                    sh """
                    ansible-playbook -i ${INVENTORY_PATH} --limit ${env.SELECTED_HOST} Playbook/${playbookFile}
                    """
                }
            }
        }
    }
}
