pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['PROD', 'UAT', 'SIT'], description: 'Choose the environment to deploy')
        choice(name: 'PLAYBOOK', choices: ['password-policy', 'install-docker', 'remove-kasperskyagent'], description: 'Choose the playbook to deploy')
        string(name: 'HOST_FILTER', defaultValue: '', description: 'Enter a host or IP to filter (optional)')
        boolean(name: 'UPDATE_REPO', defaultValue: false, description: 'Check to update the repository from GitHub.')
    }

    stages {
        stage('Update Repository') {
            when {
                expression { params.UPDATE_REPO == true }
            }
            steps {
                script {
                    // Call the script to update the repository
                    sh './configs/update_repo.sh'
                }
            }
        }

        stage('Get Hosts from Inventory') {
            steps {
                script {
                    def inventoryFile = "configs/${params.ENVIRONMENT}_inventory.ini"
                    def hostList = sh(script: "bash configs/get_hosts.sh ${inventoryFile}", returnStdout: true).trim().split('\n')
                    
                    // Filter the host list based on the user input
                    def filteredHosts = hostList.findAll { host ->
                        host.contains(params.HOST_FILTER)
                    }

                    if (filteredHosts.isEmpty()) {
                        error("No hosts found matching the filter: ${params.HOST_FILTER}")
                    } else {
                        def hostChoices = filteredHosts.join(',')
                        echo "Available hosts: ${hostChoices}"
                        
                        def selectedHosts = input(
                            id: 'userInput', 
                            message: 'Select hosts to deploy', 
                            parameters: [string(name: 'SELECTED_HOSTS', defaultValue: hostChoices)]
                        )
                        
                        currentBuild.description = "Selected Hosts: ${selectedHosts}"
                    }
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                script {
                    def inventoryFile = "configs/${params.ENVIRONMENT}_inventory.ini"
                    def playbookMap = [
                        'password-policy': 'password-policy_playbook.yml',
                        'install-docker': 'install-docker_playbook.yml',
                        'remove-kasperskyagent': 'remove-kasperskyagent_playbook.yml'
                    ]

                    def playbookFile = playbookMap[params.PLAYBOOK]
                    sh """
                    ansible-playbook -i ${inventoryFile} --limit ${params.SELECTED_HOSTS} Playbook/${playbookFile}
                    """
                }
            }
        }
    }
}
