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

        stage('Run Ansible Playbook') {
            steps {
                script {
                    // Determine the inventory file based on the selected environment
                    def inventoryFile = "configs/${params.ENVIRONMENT}_inventory.ini"

                    // Map friendly playbook names to actual file names
                    def playbookMap = "Playbook/${params.PLAYBOOK}_playbook.yml"

                    // Get the actual playbook file name based on the selected friendly name
                    def playbookFile = playbookMap[params.PLAYBOOK]

                    // Run the selected Ansible playbook with the chosen inventory
                    sh """
                    ansible-playbook -i ${inventoryFile} Playbook/${playbookFile}
                    """
                }
            }
        }
    }
}
