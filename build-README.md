# Charts

## How to push it to codeberg

helm package base --app-version "1.0.0"

curl --user [MY_MAIL] -X POST --upload-file ./base-1.0.0.tgz https://codeberg.org/api/packages/Maltazar/helm/api/charts

# How to run with a test
helm upgrade --install MYAPP base -f testval.yaml -n MYAPP --create-namespace --dry-run


## Need to do
Solve the global maps/secrets/certs so it can create a real global part, without the merge into the individual. so we dont have dublicates entries between individual configmaps.