build:
	docker build -t alchemikowner/simple-flask .
	docker image ls
login:
	docker login -u alchemikowner docker.io
push:
	docker push alchemikowner/simple-flask:latest
deploy:
	kubectl apply -f deployment.yaml
verify-deployment:
	kubectl get deployments
check-the-rollout-status:
	kubectl rollout status deployment/simple-flask-deployment
get-pods:
	kubectl get pods
describe-services:
	kubectl describe services
cluster-info:
	kubectl cluster-info
get-all-namespaces-and-pods:
	kubectl get all -A
show-all-events:
	kubectl get events -w
show-component-status:
	kubectl get componentstatuses
delete-deployment:
	kubectl delete deployments/simple-flask-deployment
