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
                    def inventoryPath = "configs/${params.ENVIRONMENT}_inventory.ini"
                    def hostList = sh(script: "configs/get_hosts.sh ${inventoryPath}", returnStdout: true).trim().split('\n')
                    
                    // Add a prompt to select hosts
                    def hostChoices = hostList.collect { it.trim() }
                    def selectedHosts = input(
                        id: 'hostInput', message: 'Select hosts to deploy', parameters: [
                            [$class: 'CascadeChoiceParameter', name: 'SELECTED_HOSTS', 
                             choiceType: 'PT_CHECKBOX', 
                             filterLength: 1, 
                             filterable: true, 
                             choices: hostChoices, 
                             description: 'Choose hosts to deploy']
                        ]
                    )

                    // Store selected hosts in a parameter
                    currentBuild.description = "Selected Hosts: ${selectedHosts.join(', ')}" // For debugging
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

                    // Run the selected Ansible playbook with the chosen inventory and host filter
                    sh """
                    ansible-playbook -i ${inventoryFile} --limit ${selectedHosts.join(',')} Playbook/${playbookFile}
                    """
                }
            }
        }
    }
}
