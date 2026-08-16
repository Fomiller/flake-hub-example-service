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
    ownerEmail = "forrestmillerj@gmail.com";
    awsRegion = "us-east-1";
    tailscale = false;
  };

  deploy = {
    envs = [ "dev" "prod" ];
    registry = "000000000000.dkr.ecr.us-east-1.amazonaws.com";
    roleToAssume = "arn:aws:iam::000000000000:role/github-actions";
    replicas = 2;
  };
}
