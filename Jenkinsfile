pipeline {
    agent { label 'master'}
    environment {
        CONTAINER = 'gomap'
        IMAGE = 'GOMAP'
        VERSION = '1.3.1'
        ZENODO_KEY = credentials('zenodo')
    }
    
    stages {
        stage('Build') {
            steps {
                sh '''
                    singularity --version && \
                    ls -lah && \
                    mkdir tmp
                    singularity exec /mnt/${CONTAINER}/${IMAGE}/${VERSION}/${IMAGE}.sif pwd
                '''
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
                sh '''
                    echo ./test.sh
                '''
            }
        } 
    }
    post { 
        success { 
            echo 'GOMAP image is successfully tested'
            sh '''
                #echo python3 zenodo_upload.py ${ZENODO_KEY}
                cd docs
                virtualenv -p python3 venv
                pip install -r requirements.txt 
                make build
                rsync -ruv  
            '''
        }
    }
}
