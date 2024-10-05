pipeline {
    agent any

    // Define a parameter to select the environment
    parameters {
        choice(name: 'ENVIRONMENT', choices: ['production', 'uat'], description: 'Choose the environment to deploy')
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Checkout your repository
                git branch: 'main', url: 'https://github.com/Sala-Cloud/SIT.git'
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                script {
                    // Determine the inventory file based on the selected environment
                    def inventoryFile = "configs/${params.ENVIRONMENT}_inventory.ini"
                    
                    // Run the Ansible playbook with the selected inventory
                    sh """
                    ansible-playbook -i ${inventoryFile} Playbook/install-apache-container.yml
                    """
                }
            }
        }
    }
}
