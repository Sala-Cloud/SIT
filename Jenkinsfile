pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['PROD', 'UAT', 'SIT'], description: 'Choose the environment to deploy')
        choice(name: 'PLAYBOOK', choices: ['password-policy', 'install-docker', 'remove-kasperskyagent'], description: 'Choose the playbook to deploy')
        string(name: 'HOST_FILTER', defaultValue: '', description: 'Enter a host or IP to filter (optional)')
        boolean(name: 'UPDATE_REPO', defaultValue: false, description: 'Check to update the repository from GitHub.')
        activeChoice(name: 'SELECTED_HOSTS', 
            description: 'Select hosts to deploy',
            groovy: '''
                def inventoryFile = "configs/${params.ENVIRONMENT}_inventory.ini"
                def hostList = []
                if (new File(inventoryFile).exists()) {
                    hostList = sh(script: "bash configs/get_hosts.sh ${inventoryFile}", returnStdout: true).trim().split('\n')
                }
                return hostList
            ''', 
            filterable: true,
            choiceType: 'PT_CHECKBOX'
        )
    }
properties([
  parameters([
    [
      $class: 'ChoiceParameter',
      choiceType: 'PT_SINGLE_SELECT',
      name: 'Environment',
      script: [
        $class: 'ScriptlerScript',
        scriptlerScriptId:'Environments.groovy'
      ]
    ],
    [
      $class: 'CascadeChoiceParameter',
      choiceType: 'PT_SINGLE_SELECT',
      name: 'Host',
      referencedParameters: 'Environment',
      script: [
        $class: 'ScriptlerScript',
        scriptlerScriptId:'HostsInEnv.groovy',
        parameters: [
          [name:'Environment', value: '$Environment']
        ]
      ]
   ]
 ])
])

pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        echo "${params.Environment}"
        echo "${params.Host}"
      }
    }
  }
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
                    // The hosts are dynamically populated through the SELECTED_HOSTS parameter
                    if (params.SELECTED_HOSTS.isEmpty()) {
                        error("No hosts found in the selected inventory.")
                    } else {
                        echo "Available hosts: ${params.SELECTED_HOSTS.join(', ')}"
                        currentBuild.description = "Selected Hosts: ${params.SELECTED_HOSTS.join(', ')}"
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
                    ansible-playbook -i ${inventoryFile} --limit ${params.SELECTED_HOSTS.join(',')} Playbook/${playbookFile}
                    """
                }
            }
        }
    }
}
