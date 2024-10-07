properties([
  parameters([
    // Select environment (DEV, TEST, STAGE, PROD)
    [
      $class: 'ChoiceParameter',
      choiceType: 'PT_SINGLE_SELECT',
      name: 'Environment',
      script: [
        $class: 'ScriptlerScript',
        scriptlerScriptId: 'Environments.groovy'  // References the Environment.groovy script
      ]
    ],
    // Cascade choice for selecting hosts based on selected environment
    [
      $class: 'CascadeChoiceParameter',
      choiceType: 'PT_SINGLE_SELECT',
      name: 'Host',
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
])

pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        echo "Selected Environment: ${params.Environment}"
        echo "Selected Host: ${params.Host}"
      }
    }
  }
}
