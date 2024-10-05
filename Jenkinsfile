pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['PROD', 'UAT', 'SIT'], description: 'Choose the environment to deploy')
        choice(name: 'PLAYBOOK', choices: ['password-policy', 'install-docker', 'remove-kasperskyagent'], description: 'Choose the playbook to deploy')
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
                    // Use the environment parameter to set the correct inventory path
                    def inventoryFile = "configs/${params.ENVIRONMENT}_inventory.ini"
                    
                    // Run the get_hosts.sh script to fetch the list of hosts
                    def hostList = sh(script: "bash configs/get_hosts.sh ${inventoryFile}", returnStdout: true).trim().split('\n')
                    
                    // Filter options for user input
                    def hostChoices = hostList.join(',')
                    echo "Available hosts: ${hostChoices}"
                    
                    // Prompt user for input
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
                    ansible-playbook -i ${inventoryFile} --limit ${selectedHosts} Playbook/${playbookFile}
                    """
                }
            }
        }
    }
}
