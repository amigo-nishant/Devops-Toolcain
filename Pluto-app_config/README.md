Command to create the custom helm chart from scratch
helm create <chart_name>
Above command will create a directory with the chart name and by default it consists following content

Chart.yaml :  Metadata about chart
Charts directory : It consists the dependency charts for the main chart.
template directory: It has the collection of kubermetes manifest files with dynamic content.
values.yaml: Custom values which will be replaced for the templates.

Note: Need to create a kubernetes secret manually for adding the TLS certificate for secure connection to the application.
kubectl create secret tls pluto-frontend-tls --key tweeny.key --cert tweeny_bundle.crt -n devtesting
Command to run the helm chart to deploy the application to the kubernetes cluster:
helm upgrade --install pluto <chart_direcotry_path> --values <values_path> --namespace 
The application requires 3 environment variables to operate, so we have created a custom configmap to add those environment variables and attached them to the deployment manifest.
The ingress controller will be used to control the incoming traffic to the application by defining the traffic rules and it perform the TLS termination.
Initial version of Pluto frontend-service can be accessible from the domain https://plutoapp.tweeny.in