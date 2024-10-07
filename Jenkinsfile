properties([
  parameters([
<<<<<<< HEAD
    // Select environment (DEV, TEST, STAGE, PROD)
=======
>>>>>>> e740bf270ec7b2910a2431de96666d298722bdae
    [
      $class: 'ChoiceParameter',
      choiceType: 'PT_SINGLE_SELECT',
      name: 'Environment',
      script: [
        $class: 'ScriptlerScript',
<<<<<<< HEAD
        scriptlerScriptId: 'Environments.groovy'  // References the Environment.groovy script
      ]
    ],
    // Cascade choice for selecting hosts based on selected environment
=======
        scriptlerScriptId:'Environments.groovy'
      ]
    ],
>>>>>>> e740bf270ec7b2910a2431de96666d298722bdae
    [
      $class: 'CascadeChoiceParameter',
      choiceType: 'PT_SINGLE_SELECT',
      name: 'Host',
<<<<<<< HEAD
      referencedParameters: 'Environment',  // Dependent on 'Environment' selection
      script: [
        $class: 'ScriptlerScript',
        scriptlerScriptId: 'HostsInEnv.groovy',  // References the HostsInEnv.groovy script
        parameters: [
          [name: 'Environment', value: '$Environment']  // Pass environment as parameter
        ]
      ]
    ]
  ])
=======
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
>>>>>>> e740bf270ec7b2910a2431de96666d298722bdae
])

pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
<<<<<<< HEAD
        echo "Selected Environment: ${params.Environment}"
        echo "Selected Host: ${params.Host}"
=======
        echo "${params.Environment}"
        echo "${params.Host}"
>>>>>>> e740bf270ec7b2910a2431de96666d298722bdae
      }
    }
  }
}
