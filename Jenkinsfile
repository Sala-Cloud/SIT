pipeline {
    agent any

    parameters {
        // Choose the environment (inventory)
        choice(name: 'ENVIRONMENT', choices: ['PROD', 'UAT', 'SIT'], description: 'Choose the environment to deploy')

        // Choose the playbook to run with user-friendly names
        choice(name: 'PLAYBOOK', choices: ['password-policy', 'install-docker', 'remove-kasperskyagent'], description: 'Choose the playbook to deploy')
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Checkout your repository where the playbooks and inventory files are located
                git branch: 'main', url: 'https://github.com/Sala-Cloud/SIT.git'
            }
        }

        stage('Get Hosts from Inventory') {
            steps {
                script {
                    // Determine the inventory file based on the selected environment
                    def inventoryFile = "configs/${params.ENVIRONMENT}_inventory.ini"
                    
                    // Parse the inventory file to get the list of hosts
                    def hostList = sh(
                        script: "grep -E '^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+' ${inventoryFile}",
                        returnStdout: true
                    ).trim().split('\n')

                    // Check if any hosts were found
                    if (hostList.isEmpty()) {
                        error "No hosts found in the inventory file: ${inventoryFile}"
                    }

                    // Create a checkbox input for the hosts
                    def selectedHosts = input(
                        id: 'userInput', message: 'Select hosts to deploy', parameters: hostList.collect { host ->
                            [$class: 'BooleanParameterDefinition', name: host.trim(), defaultValue: false, description: "Deploy to ${host.trim()}"]
                        }
                    )

                    // Filter selected hosts
                    def selectedHostList = hostList.findAll { host ->
                        selectedHosts[host.trim()]
                    }

                    // Store the selected hosts as a string for later use
                    env.HOST_FILTER = selectedHostList.join(',')
                }
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
                    ansible-playbook -i ${inventoryFile} --limit ${env.HOST_FILTER} -u Sysadmin Playbook/${playbookFile}
                    """
                }
            }
        }
    }
}
