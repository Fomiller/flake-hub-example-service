{
  name = "flake-hub-example-service";
  description = "A Go service managed by flake-hub, with infra and a chart";
  codeowners = [ "@Fomiller" ];

  language = "go";

  service = {
    container = true;
    port = 8080;
  };

  infra = {
    envs = [ "dev" "prod" ];
    dopplerProject = "flake-hub-example-service";
    stateBucket = "fomiller-tfstate-all";
    awsRegion = "us-east-1";
    tailscale = false;
  };

  deploy = {
    ecrRepo = "charts";
    roleToAssume = "arn:aws:iam::000000000000:role/github-actions";
    replicas = 2;
  };
}
