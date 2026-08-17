{
  name = "flake-hub-example-service";
  namePrefix = "flake-hub-";
  description = "A Go service managed by flake-hub, with infra and a chart";

  language = "go";

  github = {
    codeowners = [ "@Fomiller" ];
    roleToAssume = "arn:aws:iam::000000000000:role/github-actions";
  };

  service = {
    container = true;
    port = 8080;
  };

  infra = {
    dopplerProject = "flake-hub-example-service";
    ownerEmail = "forrestmillerj@gmail.com";
    environments.dev = {
      stateBucket = "fomiller-tfstate-all";
      profile = "fomiller-dev";
    };
  };

  docs = {
    authors = [ "Forrest Miller" ];
    repoUrl = "https://github.com/Fomiller/flake-hub-example-service";
  };

  argocd = {
    environments = [ "dev" ];
    registry = "000000000000.dkr.ecr.us-east-1.amazonaws.com";
    replicas = 2;
  };
}
