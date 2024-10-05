pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['PROD', 'UAT', 'SIT'], description: 'Choose the environment to deploy')
        choice(name: 'PLAYBOOK', choices: ['password-policy', 'install-docker', 'remove-kasperskyagent'], description: 'Choose the playbook to deploy')
        string(name: 'HOST_FILTER', defaultValue: '', description: 'Enter a host or IP to filter (optional)')
        choice(name: 'UPDATE_REPO', choices: ['No Update', 'Update Repo', 'Update Repo and Deploy'], description: 'Select to update the repository or not.')
        
        // Use Extended Choice Parameter Plugin for host selection
        cascadeChoice(name: 'SELECTED_HOSTS', 
                      description: 'Select hosts to deploy', 
                      choiceType: 'PT_CHECKBOX', 
                      filterLength: 1, 
                      filterable: true, 
                      randomName: 'selectedHosts', 
                      script: [
                          classpath: [],
                          fallbackScript: [
                              class: 'org.codehaus.groovy.runtime.ScriptBytecodeAdapter$WrappedClosure',
                              script: "return ['No hosts available']"
                          ],
                          script: [
                              class: 'org.codehaus.groovy.runtime.ScriptBytecodeAdapter$WrappedClosure',
                              script: "def inventoryFile = \"configs/${params.ENVIRONMENT}_inventory.ini\"; \
                                        def hostList = sh(script: \"bash configs/get_hosts.sh ${inventoryFile}\", returnStdout: true).trim().split('\\n'); \
                                        return hostList"
                          ]
                      ])
    }

    stages {
        stage('Update Repository') {
            when {
                expression { params.UPDATE_REPO == 'Update Repo' || params.UPDATE_REPO == 'Update Repo and Deploy' }
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
                    // This stage is now handled by the Extended Choice Parameter in the parameters block
                    echo "Selected Hosts: ${params.SELECTED_HOSTS}"
                }
            }
        }

        stage('Run Ansible Playbook') {
            when {
                expression { params.UPDATE_REPO == 'Update Repo and Deploy' || params.UPDATE_REPO == 'No Update' }
            }
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
