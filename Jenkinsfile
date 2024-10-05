pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['PROD', 'UAT', 'SIT'], description: 'Choose the environment to deploy')
        choice(name: 'PLAYBOOK', choices: ['password-policy', 'install-docker', 'remove-kasperskyagent'], description: 'Choose the playbook to deploy')
        string(name: 'HOST_FILTER', defaultValue: '', description: 'Enter a host or IP to filter (optional)')
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/Sala-Cloud/SIT.git'
            }
        }

        stage('Get Hosts from Inventory') {
            steps {
                script {
                    // Use the selected environment to define the inventory file path
                    def inventoryFile = "configs/${params.ENVIRONMENT}_inventory.ini"
                    
                    // Fetch the list of hosts from the inventory file
                    def hostList = sh(script: "bash configs/get_hosts.sh ${inventoryFile}", returnStdout: true).trim().split('\n')
                    
                    // Filter the host list based on the user input
                    def filteredHosts = hostList.findAll { host ->
                        host.contains(params.HOST_FILTER)
                    }

                    // Display filtered hosts for selection
                    if (filteredHosts.isEmpty()) {
                        error("No hosts found matching the filter: ${params.HOST_FILTER}")
                    } else {
                        def hostChoices = filteredHosts.join(',')
                        echo "Available hosts: ${hostChoices}"
                        
                        // Prompt user for input to select hosts
                        def selectedHosts = input(
                            id: 'userInput', 
                            message: 'Select hosts to deploy', 
                            parameters: [string(name: 'SELECTED_HOSTS', defaultValue: hostChoices)]
                        )
                        
                        // Store the selected hosts for later use
                        currentBuild.description = "Selected Hosts: ${selectedHosts}"
                    }
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                script {
                    // Prepare inventory file path and playbook mapping
                    def inventoryFile = "configs/${params.ENVIRONMENT}_inventory.ini"
                    def playbookMap = [
                        'password-policy': 'password-policy_playbook.yml',
                        'install-docker': 'install-docker_playbook.yml',
                        'remove-kasperskyagent': 'remove-kasperskyagent_playbook.yml'
                    ]

                    def playbookFile = playbookMap[params.PLAYBOOK]

                    // Run the selected Ansible playbook with the chosen inventory and selected hosts
                    sh """
                    ansible-playbook -i ${inventoryFile} --limit ${params.SELECTED_HOSTS} Playbook/${playbookFile}
                    """
                }
            }
        }
    }
}
