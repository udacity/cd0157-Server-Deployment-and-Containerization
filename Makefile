create-venv:
	pyenv virtualenv udacity-deployment-project
	echo udacity-deployment-project > venv

delete-venv:
	pyenv virtualenv-delete udacity-deployment-project
	rm venv

build-image:
	docker build -t myimage .

list-images:
	docker image ls

remove-image:
	docker image rm myimage

# For local run use post 8080, for containerized runs port 80
run-container:
	docker run --name myContainer --env-file=.docker_env -p 80:8080 myimage
	docker container ls
	docker container ps

list-containers:
	docker container ls

stop-container:
	docker container stop myContainer

remove-container:
	docker container rm myContainer
