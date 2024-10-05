pipeline {
    agent any

    parameters {
        // Choose the environment (inventory)
        choice(name: 'ENVIRONMENT', choices: ['PROD', 'UAT', 'SIT'], description: 'Choose the environment to deploy')

        // Choose the playbook to run with user-friendly names
        choice(name: 'PLAYBOOK', choices: ['password-policy', 'install-docker', 'remove-kasperskyagent'], description: 'Choose the playbook to deploy')

        // Allow input for specific hostname or IP address
        string(name: 'HOST_FILTER', defaultValue: '', description: 'Enter a specific hostname or IP address to target (leave empty to target all)')
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
                    def playbookMap = [
                        'password-policy': 'password-policy_playbook.yml',
                        'install-docker': 'install-docker_playbook.yml',
                        'remove-kasperskyagent': 'remove-kasperskyagent_playbook.yml'
                    ]

                    // Get the actual playbook file name based on the selected friendly name
                    def playbookFile = playbookMap[params.PLAYBOOK]

                    // Add filtering based on the HOST_FILTER parameter
                    def hostFilter = params.HOST_FILTER ? "--limit ${params.HOST_FILTER}" : ""

                    // Run the selected Ansible playbook with the chosen inventory and host filter
                    sh """
                    ansible-playbook -i ${inventoryFile} ${hostFilter} Playbook/${playbookFile}
                    """
                }
            }
        }
    }
}
