    pipeline {
    agent any

    stages {
        stage('Clone Repository') {
            steps {
                // Checkout your repository
                git branch: 'main', url: 'https://github.com/Sala-Cloud/SIT.git'
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                // Example: Run Ansible with the inventory located in 'configs/inventory.ini'
                sh '''
                ansible-playbook -i configs/inventory.ini Playbook/install-apache-container.yml
                '''
            }
        }
    }
}
