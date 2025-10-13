pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
        disableResume()
    }

    environment {
        REGISTRY = 'pipeline21.kaltoo.click'
        REPO_URL = 'https://gitlab+deploy-token-9415643:gldt-phnnivHFXBm_ssjH6y7Q@gitlab.com/wastelocker/emisdetas.git'
        ENV_FILE = '/opt/emisdetas/env/.env'
        BRANCH = 'dev'
    }

    stages {
        stage('Inform users') {
            steps {
                echo 'Build started for all images (estimated 23 min).'
                sh '''
                curl -H "Content-Type: application/json" \
                    -X POST \
                    -d '{"content": "Build started for all images (estimated 23 min)"}' \
                    https://discord.com/api/webhooks/1426959332267790617/lpHUuTPxGBwQPBTu-42uJjl4P9UOevnVIg8z37w4B-cqEkRoK82NSK0sEwmPuhwbr30Y
            '''
            }
        }
        stage('Clean workspace (before build)') {
            steps {
                echo "Cleaning workspace before build..."
                deleteDir()
                sh '''
                    echo "Cleaning unused Docker resources..."
                    docker system prune -af || true
                '''
            }
        }
        stage('Checkout repository') {
            steps {
                sh '''
                    if [ -d emisdetas ]; then
                        echo "Updating existing repository..."
                        cd emisdetas
                        git fetch origin ${BRANCH}
                        git reset --hard origin/${BRANCH}
                        git checkout ${BRANCH}
                    else
                        echo "Cloning ${BRANCH} branch..."
                        git clone --branch ${BRANCH} ${REPO_URL} emisdetas
                    fi
                '''
            }
        }

        stage('Build and pull images') {
            steps {
                dir('emisdetas') {
                    sh '''
                        echo "Loading environment variables from ${ENV_FILE}..."
                        set -o allexport
                        source ${ENV_FILE} || true
                        set +o allexport

                        echo "Pulling prebuilt images..."
                        docker compose --env-file ${ENV_FILE} pull || true

                        echo "Building locally defined images..."
                        docker compose --env-file ${ENV_FILE} build --parallel
                    '''
                }
            }
        }

        stage('Push all images to private registry') {
            steps {
                dir('emisdetas') {
                    sh '''
                        echo "Logging into ${REGISTRY}..."
                        docker login https://${REGISTRY} -u admin -p valfireraintammepuusavialus

                        echo "Enumerating all images..."
                        ALL_IMAGES=$(docker compose --env-file ${ENV_FILE} config | grep 'image:' | awk '{print $2}' | sort -u)

                        echo "Images detected:"
                        echo "$ALL_IMAGES"

                        if [ -z "$ALL_IMAGES" ]; then
                            echo "No images found in docker-compose definition."
                            exit 1
                        fi

                        for img in $ALL_IMAGES; do
                            echo "Processing image: $img"

                            # Ensure image exists locally
                            if ! docker image inspect "$img" > /dev/null 2>&1; then
                                echo "Image not found locally, pulling $img..."
                                docker pull "$img" || true
                            fi

                            # Extract original image path and tag
                            name="${img%%:*}"
                            tag="${img##*:}"

                            # If there's no tag, assume latest
                            if [ "$name" = "$tag" ]; then
                                tag="latest"
                            fi

                            # Prepend registry but keep repo and tag
                            new_tag="${REGISTRY}/${name}:${tag}"

                            echo "Tagging $img as $new_tag"
                            docker tag "$img" "$new_tag"

                            echo "Pushing $new_tag ..."
                            docker push "$new_tag" || echo "Failed to push $img"
                        done
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning workspace and Docker cache after build..."
            deleteDir()
            sh '''
                docker system prune -af || true
                docker volume prune -f || true
            '''
        }
        success {
            echo 'All images successfully built/pulled and pushed to private registry from dev branch!'
            sh '''
            curl -H "Content-Type: application/json" \
                 -X POST \
                 -d '{"content": "**Build successful (all images)**"}' \
                 https://discord.com/api/webhooks/1426959332267790617/lpHUuTPxGBwQPBTu-42uJjl4P9UOevnVIg8z37w4B-cqEkRoK82NSK0sEwmPuhwbr30Y
        '''
            
        }
        failure {
            echo 'Build or push failed. Check logs above.'
            sh '''
            curl -H "Content-Type: application/json" \
                 -X POST \
                 -d '{"content": "**Build failed (all images)**"}' \
                 https://discord.com/api/webhooks/1426959332267790617/lpHUuTPxGBwQPBTu-42uJjl4P9UOevnVIg8z37w4B-cqEkRoK82NSK0sEwmPuhwbr30Y
        '''
        }
    }
}
