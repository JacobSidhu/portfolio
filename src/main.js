import './styles.css';

const colors = ['#ffbaba', '#ccccff', '#fef7ff', '#cfe5c3', '#ffb0e6'];
const navItems = document.querySelectorAll('.top-bar a');
const glowDots = document.querySelectorAll('.dot-row span');
const homePanel = document.querySelector('[data-panel="home"]');
const aboutPanel = document.querySelector('[data-panel="about"]');
const contactPanel = document.querySelector('[data-panel="contact"]');
const skillsPanel = document.querySelector('[data-panel="skills"]');
const projectsPanel = document.querySelector('[data-panel="projects"]');
const certificationsPanel = document.querySelector('[data-panel="certifications"]');
const panels = document.querySelectorAll('[data-panel]');
const tabTriggers = document.querySelectorAll('[data-tab-trigger]');
const skillRowShells = document.querySelectorAll('.skill-row-shell');
const certificateDialog = document.querySelector('[data-cert-dialog]');
const certificateDialogOpeners = document.querySelectorAll('[data-cert-dialog-open]');
const certificateDialogClosers = document.querySelectorAll('[data-cert-dialog-close]');
const certificateModal = document.querySelector('.certificate-modal');
const certificatePreview = document.querySelector('[data-cert-preview]');
const certificationSegmentButtons = document.querySelectorAll('.certification-segmented-control button');
const certificationViews = document.querySelectorAll('[data-certification-view]');
const projectImageDialog = document.querySelector('[data-project-image-dialog]');
const projectImageOpeners = document.querySelectorAll('[data-project-image-open]');
const projectImageClosers = document.querySelectorAll('[data-project-image-close]');
const projectImageModal = document.querySelector('.image-modal');
const projectImagePreview = document.querySelector('[data-project-image-preview]');
const projectListPage = document.querySelector('[data-project-list-page]');
const projectDetailPage = document.querySelector('[data-project-detail-page]');
const projectDetailOpeners = document.querySelectorAll('[data-project-detail-open]');
const projectDetailClosers = document.querySelectorAll('[data-project-detail-close]');
const projectDetailTitle = document.querySelector('[data-project-detail-title]');
const projectDetailTabs = document.querySelectorAll('[data-project-detail-tab]');
const projectDetailPanels = document.querySelectorAll('[data-project-panel]');
const projectArchitectureFigure = document.querySelector('[data-project-architecture-figure]');
const projectArchitectureImage = document.querySelector('[data-project-architecture-image]');
const projectVersionSelect = document.querySelector('[data-project-version-select]');
let activeProjectKey = '';

const defaultProjectDetails = {
  overview:
    'This project demonstrates a practical cloud build with a clear architecture, deployment workflow, and production-minded decisions.\n\nTemporary scroll test content: this section is intentionally longer so the white project-detail window can be tested as the only scrollable area.\n\nThe final version can include the problem statement, target users, service boundaries, implementation notes, deployment flow, reliability concerns, and future improvements.\n\nAdditional placeholder paragraph for testing vertical overflow. The card should stay full height while this content scrolls inside the white content pane.\n\nAdditional placeholder paragraph for testing vertical overflow. The right-side menu and X button should remain visible while this content area scrolls.\n\nAdditional placeholder paragraph for testing vertical overflow. This confirms the project detail page behaves like a page inside the Projects tab, not like a dialog.',
  architecture:
    'The architecture view explains the key services, traffic flow, integration points, and operational boundaries of the project.\n\nTemporary scroll test content: add architecture diagrams, traffic flow, data flow, request lifecycle, failure modes, and AWS service responsibilities here.\n\nAdditional placeholder paragraph for testing scroll behavior inside the architecture section.\n\nAdditional placeholder paragraph for testing scroll behavior inside the architecture section.\n\nAdditional placeholder paragraph for testing scroll behavior inside the architecture section.',
  decision:
    'Design decisions focus on cost, maintainability, security, scalability, and keeping the implementation simple enough to operate.\n\nTemporary scroll test content: this area can explain why each service was chosen, what alternatives were rejected, and which tradeoffs were accepted.\n\nAdditional placeholder paragraph for testing scroll behavior inside the design decision section.\n\nAdditional placeholder paragraph for testing scroll behavior inside the design decision section.\n\nAdditional placeholder paragraph for testing scroll behavior inside the design decision section.',
  repo:
    'Repository details, source structure, deployment notes, and future links will live here when the project repo is finalized.\n\nTemporary scroll test content: include folder structure, setup commands, deployment commands, environment variables, and screenshots.\n\nAdditional placeholder paragraph for testing scroll behavior inside the GitHub repo section.\n\nAdditional placeholder paragraph for testing scroll behavior inside the GitHub repo section.\n\nAdditional placeholder paragraph for testing scroll behavior inside the GitHub repo section.',
  learning:
    'Key lessons, tradeoffs, blockers, and improvements discovered while building this project will be documented here.\n\nTemporary scroll test content: include what worked, what failed, what changed, and what would be improved in version 2.\n\nAdditional placeholder paragraph for testing scroll behavior inside the learning section.\n\nAdditional placeholder paragraph for testing scroll behavior inside the learning section.\n\nAdditional placeholder paragraph for testing scroll behavior inside the learning section.',
};

const projectDetails = {
  'quizx-aws-distributed-system': {
    versions: [
      {
        value: 'v1',
        label: 'Version 1.0.0',
        architectureImage: '/assets/project-quizx-aws-v1-architecture.png',
        architectureImageAlt: 'QuizX AWS distributed system version 1 architecture diagram',
        overview:
          'QuizX is a cloud-hosted multiple-choice question system deployed on AWS.\n\nThis first release provisions AWS infrastructure with Terraform, deploys a multi-container Node.js application on EC2 using Docker Compose, and automates application deployment through GitHub Actions.\n\nThe system contains two independent Node.js Express applications: a Question App for retrieving random quiz questions by category, and a Submit App for submitting new questions, answers, and categories.\n\nBoth applications communicate with a private database container over a Docker network. The database is not publicly exposed, and persistent storage is provided through a Docker volume.',
        architecture:
          'Diagram description:\nThe architecture shows a foundation AWS deployment for a distributed quiz platform. A developer pushes code to GitHub, GitHub Actions validates the application and infrastructure, then deploys to an EC2 Ubuntu instance over SSH. Terraform provisions the AWS network boundary, including VPC, public subnet, internet gateway, route table, security group, EC2 instance, and key pair.\n\nInside EC2, Docker Compose runs three containers on a private Docker network: question-app, submit-app, and database. The Question App is exposed publicly on host port 4000 and maps to container port 3000. The Submit App is exposed publicly on host port 4200 and maps to container port 3200. The database uses internal port 3306 and is not publicly exposed. Persistent data is stored in a Docker volume.\n\nFlow:\n1. Developer pushes code changes to GitHub.\n2. GitHub Actions checks out the code, runs tests/lints, validates Terraform, builds Docker images, and deploys via SSH.\n3. Terraform provisions AWS VPC, subnet, internet gateway, route table, security group, EC2, and key pair.\n4. The deployment workflow connects to EC2 over SSH on port 22.\n5. Docker Compose starts question-app, submit-app, and the database container.\n6. Users access Question App through http://<ec2-public-ip>:4000.\n7. Users access Submit App through http://<ec2-public-ip>:4200.\n8. Both applications communicate with the private database container over the Docker private network.\n\nWhy this architecture works:\nIt keeps the first release intentionally practical. EC2 gives hands-on Linux and server administration experience, Terraform makes infrastructure repeatable, Docker Compose keeps multi-container deployment simple, and GitHub Actions adds a real CI/CD path.',
        decision:
          'EC2 was chosen for this version because it exposes the fundamentals: Linux server setup, SSH access, Docker installation, security group configuration, and application deployment.\n\nDocker Compose was chosen because it can run multiple application containers and a database container with one configuration file. It also gives service-name based networking, so containers can communicate privately without hardcoded public addresses.\n\nTerraform was used so VPC, subnet, internet gateway, route table, security group, EC2, and key pair resources are defined as code and can be rebuilt consistently.\n\nGitHub Actions was used to automate validation and deployment. The CI workflow validates the project, while the deploy workflow connects to EC2 and updates the Docker Compose application.\n\nThe database is intentionally not publicly exposed. Only the application ports are public, while database traffic stays inside the Docker private network.',
        repo:
          'GitHub: https://github.com/JacobSidhu/quizx-aws-distributed-system\n\nVersion: v1.0.0-option1-terraform-cicd-ec2-docker\nStatus: Foundation release\nCloud provider: AWS\nDeployment model: Single EC2 instance, Docker Compose, Terraform, GitHub Actions\n\nRepository structure includes app/question-app, app/submit-app, database/mysql, infra/terraform, infra/docker, docs/architecture, docs/screenshots, testing notes, security notes, cost notes, and GitHub Actions workflows.',
        learning:
          'This project demonstrates the difference between building an app and deploying an app as an operating system, network, infrastructure, and CI/CD workflow.\n\nKey learning areas include Terraform resource definition, EC2 provisioning, SSH deployment, Docker Compose networking, private database access, persistent Docker volumes, GitHub Actions secrets, and practical security group configuration.\n\nThe foundation release is intentionally simple, but it gives a strong base for future versions such as load balancing, managed databases, container orchestration, private subnets, TLS, monitoring, and stronger deployment controls.',
      },
      {
        value: 'v2',
        label: 'Version 2.0.0',
        architectureImage: '/assets/project-quizx-aws-v2-architecture.png',
        architectureImageAlt: 'QuizX AWS distributed system version 2 architecture diagram',
        overview:
          'QuizX version 2.0.0 extends the foundation release into a clearer two-EC2 deployment model. The Question App and Submit App are separated onto their own EC2 Ubuntu instances while still being provisioned by Terraform and deployed through GitHub Actions over SSH.\n\nThis version keeps the project intentionally practical, but improves separation of responsibility between the read-focused question service and the write-focused submit service.',
        architecture:
          'Diagram description:\nVersion 2.0.0 separates the QuizX workload across two EC2 instances inside the same AWS VPC and public subnet. Terraform still provisions the VPC, public subnet, internet gateway, route table, security groups, EC2 instances, and key pairs. GitHub Actions remains the deployment orchestrator and connects to EC2 over SSH to deploy Docker Compose files.\n\nThe Question EC2 instance hosts the question-app container, a local database container, and an ETL container inside a Docker private network. The Submit EC2 instance hosts the submit-app container, category database container, rmq-admin, and rmq-adminv container inside its own Docker private network. Public traffic reaches the question side through port 4200 and the submit side through port 4000, while internal container communication remains private.\n\nFlow:\n1. Developer pushes code changes to GitHub.\n2. GitHub Actions checks out code, runs tests/lints, validates Terraform, builds Docker images, and deploys via SSH.\n3. Terraform provisions AWS networking and two EC2 Ubuntu instances for question and submit workloads.\n4. GitHub Actions connects to each EC2 instance over SSH on port 22.\n5. Docker Compose starts the containers on the question-app EC2 instance.\n6. Docker Compose starts the containers on the submit-app EC2 instance.\n7. Users access the question app through the question EC2 public URL.\n8. Users access the submit app through the submit EC2 public URL.\n9. Container-to-container traffic stays inside each Docker private network.\n\nWhy version 2 matters:\nSeparating the apps across EC2 instances creates a stronger distributed-system story than v1. It makes the read and write sides easier to reason about independently, gives each service its own host boundary, and prepares the project for future improvements like load balancing, private subnets, managed databases, and service-level monitoring.',
        decision:
          'Version 2.0.0 separates Question App and Submit App infrastructure because the two services have different responsibilities. The Question App is read-focused, while the Submit App is write-focused and includes additional supporting containers.\n\nTwo EC2 instances make the architecture more distributed while still staying understandable for a foundation AWS project. Terraform keeps provisioning repeatable, Docker Compose keeps host-level container orchestration simple, and GitHub Actions keeps deployment automated.\n\nThe design still avoids exposing databases publicly. Application ports are exposed for user access, SSH is restricted, and database/container communication remains inside Docker private networks.',
        repo:
          'GitHub: https://github.com/JacobSidhu/quizx-aws-distributed-system\n\nVersion: 2.0.0\nArchitecture: two EC2 Ubuntu instances, Terraform-provisioned AWS networking, Docker Compose runtime, and GitHub Actions SSH deployment.\n\nThe v2 diagram documents the split between question-app infrastructure and submit-app infrastructure, including public ports, private Docker networks, route table, internet gateway, security groups, and internal database/container traffic.',
        learning:
          'Version 2.0.0 improves the project by moving from one EC2 host running all application containers to a clearer distributed layout with separate EC2 instances.\n\nThe main learning is service separation: splitting read and write concerns across hosts changes deployment, networking, security group design, and operational thinking.\n\nThis version is a useful step before more production-grade AWS patterns such as Application Load Balancers, autoscaling groups, private subnets, RDS, ECR, ECS, CloudWatch dashboards, and centralized logging.',
      },
    ],
  },
  'realtime-data-management': {
    architectureImage: '/assets/project-realtime-data-management-architecture.png',
    architectureImageAlt: 'Real-time data management architecture diagram',
    overview:
      'A real-time data processing service built on AWS. A producer Lambda sends JSON event records to Amazon Kinesis Data Streams, and a consumer Lambda processes each stream record before writing the result into DynamoDB.\n\nThe project demonstrates an event-driven ingestion flow where data is accepted, buffered, processed, and persisted without managing servers.\n\nTemporary scroll test content: this paragraph exists to verify that the content pane scrolls while the project card remains full height.\n\nThe producer and consumer responsibilities are separated so each Lambda function has a focused purpose. That also makes debugging and operational review easier.\n\nKinesis acts as the handoff point between ingestion and processing, giving the workflow a more realistic streaming architecture than direct Lambda-to-DynamoDB writes.\n\nCloudWatch Logs supports troubleshooting for producer events, consumer processing, and failed payload handling.\n\nAdditional placeholder paragraph for testing scroll behavior. This will be replaced with final project details later.',
    architecture:
      'Diagram description:\nThe architecture shows a serverless real-time data pipeline inside AWS Cloud. A user or test event invokes a Lambda producer inside the public subnet. The producer sends JSON records into Amazon Kinesis Data Streams. Kinesis then triggers a Lambda consumer through an event source mapping. The consumer decodes the stream payload and writes processed items into Amazon DynamoDB. Both Lambda functions publish logs and monitoring output to Amazon CloudWatch Logs.\n\nFlow:\n1. User / test event invokes the producer Lambda.\n2. Producer Lambda validates and serializes the event payload.\n3. Producer Lambda writes the event to Kinesis Data Streams with put_record().\n4. Kinesis buffers the record and invokes the consumer Lambda through the stream trigger.\n5. Consumer Lambda decodes and processes the record.\n6. Consumer Lambda stores the processed item in DynamoDB with put_item().\n7. Producer and consumer Lambda logs are sent to CloudWatch for troubleshooting and monitoring.\n\nWhy this architecture works:\nKinesis separates ingestion from processing, which makes the pipeline more resilient than a direct Lambda-to-DynamoDB write path. Lambda keeps compute serverless, DynamoDB provides fast persistence, and CloudWatch gives a clear operational trail for debugging.',
    decision:
      'Kinesis separates ingestion from processing so events can be buffered and consumed reliably. Lambda keeps compute serverless, DynamoDB gives low-latency writes, and CloudWatch provides basic operational visibility.\n\nThe producer and consumer are separate because it keeps responsibilities clean: one function sends events into the stream, the other processes records from the stream.\n\nDynamoDB is a good fit for this project because the data model is simple, writes are fast, and it avoids operating a database server.\n\nCloudWatch is included because serverless systems still need logs, metrics, and troubleshooting paths.\n\nTemporary scroll test content: this paragraph helps confirm the design decision section scrolls correctly.\n\nAdditional placeholder paragraph for testing scroll behavior. Final content can include rejected alternatives and cost/security notes.',
    repo:
      'GitHub: https://github.com/JacobSidhu/real-time-data-management-service\n\nThe repository contains separate producer and consumer Lambda folders, screenshots, README documentation, and the architecture diagram.\n\nThe README describes the pipeline as an AWS Lambda, Amazon Kinesis Data Streams, and Amazon DynamoDB project.\n\nTemporary scroll test content: add setup instructions, AWS prerequisites, deployment notes, and test event examples here.\n\nSuggested final repo section: repository structure, how to run or deploy, screenshots, architecture file, and future improvements.\n\nAdditional placeholder paragraph for testing scroll behavior.',
    learning:
      'This project shows event-source mapping, producer and consumer Lambda separation, stream payload decoding, DynamoDB writes, and the monitoring path needed for a serverless streaming workflow.\n\nThe key learning is that real-time architecture is mostly about boundaries: where data enters, where it is buffered, where it is processed, and where failures can be observed.\n\nSeparating the producer and consumer makes the flow easier to reason about and closer to how production event pipelines are usually structured.\n\nTemporary scroll test content: this paragraph helps test vertical overflow in the learning panel.\n\nAdditional placeholder paragraph for testing scroll behavior. Later this can become a concise write-up of blockers, fixes, and next improvements.',
  },
};

function shuffledColors() {
  return [...colors].sort(() => Math.random() - 0.5);
}

function updateGlowColors() {
  shuffledColors().forEach((color, index) => {
    glowDots[index].style.setProperty('--dot-color', color);
  });
}

function replayHomeAnimation() {
  homePanel.classList.add('is-animating');
  window.requestAnimationFrame(() => {
    homePanel.classList.remove('is-animating');
  });
}

function replayAboutAnimation() {
  aboutPanel.classList.add('is-animating');
  window.requestAnimationFrame(() => {
    aboutPanel.classList.remove('is-animating');
  });
}

function replayContactAnimation() {
  contactPanel.classList.add('is-animating');
  window.requestAnimationFrame(() => {
    contactPanel.classList.remove('is-animating');
  });
}

function replaySkillsAnimation() {
  skillsPanel.classList.add('is-animating');
  window.requestAnimationFrame(() => {
    skillsPanel.classList.remove('is-animating');
  });
}

function replayProjectsAnimation() {
  projectsPanel.classList.add('is-animating');
  window.requestAnimationFrame(() => {
    projectsPanel.classList.remove('is-animating');
  });
}

function replayCertificationsAnimation() {
  certificationsPanel.classList.add('is-animating');
  window.requestAnimationFrame(() => {
    certificationsPanel.classList.remove('is-animating');
  });
}

function activateTab(tabName) {
  navItems.forEach((navItem) => {
    navItem.classList.toggle('active', navItem.dataset.tab === tabName);
  });
  panels.forEach((panel) => {
    panel.classList.toggle('is-hidden', panel.dataset.panel !== tabName);
  });
  if (tabName === 'home') {
    replayHomeAnimation();
  }
  if (tabName === 'about') {
    replayAboutAnimation();
  }
  if (tabName === 'contact') {
    replayContactAnimation();
  }
  if (tabName === 'skills') {
    replaySkillsAnimation();
  }
  if (tabName === 'projects') {
    showProjectListPage();
    replayProjectsAnimation();
  }
  if (tabName === 'certifications') {
    replayCertificationsAnimation();
  }
  updateGlowColors();
  updateSkillRowControls();
}

function showProjectListPage() {
  projectDetailPage.hidden = true;
  projectListPage.hidden = false;
  projectsPanel.scrollTo({ top: 0, behavior: 'smooth' });
}

function showProjectDetailPage() {
  projectListPage.hidden = true;
  projectDetailPage.hidden = false;
  projectsPanel.scrollTo({ top: 0, behavior: 'smooth' });
  projectDetailPage.focus();
}

function getActiveScrollPanel() {
  return Array.from(panels).find((panel) => !panel.classList.contains('is-hidden') && panel.scrollHeight > panel.clientHeight + 1);
}

function isInsideScrollableElement(target) {
  const scrollableElement = target.closest('.skill-card-row, .project-detail-content, .certificate-modal, .image-modal');

  if (!scrollableElement) {
    return false;
  }

  return scrollableElement.scrollHeight > scrollableElement.clientHeight + 1
    || scrollableElement.scrollWidth > scrollableElement.clientWidth + 1;
}

function routeWheelToActivePanel(event) {
  if (isInsideScrollableElement(event.target)) {
    return;
  }

  const activePanel = getActiveScrollPanel();

  if (!activePanel) {
    return;
  }

  event.preventDefault();
  activePanel.scrollBy({
    top: event.deltaY,
    left: event.deltaX,
    behavior: 'auto',
  });
}

function updateSkillRowControls() {
  skillRowShells.forEach((shell) => {
    const row = shell.querySelector('.skill-card-row');
    const previous = shell.querySelector('[data-skill-scroll="previous"]');
    const next = shell.querySelector('[data-skill-scroll="next"]');

    if (!row || !previous || !next) {
      return;
    }

    const maxScroll = Math.max(0, row.scrollWidth - row.clientWidth);
    const isScrollable = maxScroll > 1;
    shell.classList.toggle('is-not-scrollable', !isScrollable);
    previous.hidden = !isScrollable || row.scrollLeft <= 1;
    next.hidden = !isScrollable || row.scrollLeft >= maxScroll - 1;
  });
}

function openCertificateDialog(event) {
  certificatePreview.src = event.currentTarget.dataset.certImage || '/assets/cert-terraform-associate-full.png';
  certificatePreview.alt = event.currentTarget.dataset.certAlt || 'Terraform Associate certificate';
  certificateDialog.hidden = false;
  certificateModal.focus();
}

function closeCertificateDialog() {
  certificateDialog.hidden = true;
  certificatePreview.src = '/assets/cert-terraform-associate-full.png';
  certificatePreview.alt = 'Terraform Associate certificate';
}

function openProjectImageDialog(event) {
  const image = event.currentTarget.querySelector('img');

  if (!image) {
    return;
  }

  projectImagePreview.src = image.currentSrc || image.src;
  projectImagePreview.alt = image.alt;
  projectImageDialog.hidden = false;
  projectImageModal.focus();
}

function closeProjectImageDialog() {
  projectImageDialog.hidden = true;
  projectImagePreview.src = '';
  projectImagePreview.alt = '';
}

function setProjectDetailPanel(panelName) {
  projectDetailTabs.forEach((tab) => {
    tab.classList.toggle('active', tab.dataset.projectDetailTab === panelName);
  });
  projectDetailPanels.forEach((panel) => {
    panel.hidden = panel.dataset.projectPanel !== panelName;
  });
}

function appendProjectParagraph(container, lines) {
  if (!lines.length) {
    return;
  }

  const paragraph = document.createElement('p');
  paragraph.textContent = lines.join('\n');
  container.append(paragraph);
}

function appendProjectTextBlock(container, block) {
  const lines = block.split('\n').map((line) => line.trim()).filter(Boolean);

  if (!lines.length) {
    return;
  }

  const headingLine = lines[0].endsWith(':') ? lines.shift() : '';

  if (headingLine) {
    const heading = document.createElement('h4');
    heading.textContent = headingLine.slice(0, -1);
    container.append(heading);
  }

  if (!lines.length) {
    return;
  }

  const isNumberedList = lines.every((line) => /^\d+\.\s/.test(line));

  if (isNumberedList) {
    const list = document.createElement('ol');

    lines.forEach((line) => {
      const item = document.createElement('li');
      item.textContent = line.replace(/^\d+\.\s/, '');
      list.append(item);
    });

    container.append(list);
    return;
  }

  appendProjectParagraph(container, lines);
}

function renderProjectCopy(container, text) {
  container.replaceChildren();

  text
    .split(/\n{2,}/)
    .map((block) => block.trim())
    .filter(Boolean)
    .forEach((block) => appendProjectTextBlock(container, block));
}

function updateProjectDetailCopy(projectKey) {
  const project = projectDetails[projectKey];
  const versionedDetails = project?.versions;
  const selectedVersion = projectVersionSelect.value;
  const details = versionedDetails?.find((version) => version.value === selectedVersion)
    || versionedDetails?.[0]
    || project
    || defaultProjectDetails;

  projectDetailPanels.forEach((panel) => {
    const copy = panel.querySelector('[data-project-panel-copy]');

    if (!copy) {
      return;
    }

    renderProjectCopy(
      copy,
      details[panel.dataset.projectPanel] || defaultProjectDetails[panel.dataset.projectPanel],
    );
  });

  if (details.architectureImage) {
    projectArchitectureImage.src = details.architectureImage;
    projectArchitectureImage.alt = details.architectureImageAlt || 'Project architecture diagram';
    projectArchitectureFigure.hidden = false;
  } else {
    projectArchitectureFigure.hidden = true;
    projectArchitectureImage.src = '';
    projectArchitectureImage.alt = '';
  }
}

function updateProjectVersionOptions(projectKey) {
  const versions = projectDetails[projectKey]?.versions || [{ value: 'v1', label: 'Version 1.0.0' }];

  projectVersionSelect.replaceChildren();
  versions.forEach((version) => {
    const option = document.createElement('option');
    option.value = version.value;
    option.textContent = version.label;
    projectVersionSelect.append(option);
  });
  projectVersionSelect.value = versions[0].value;
  projectVersionSelect.hidden = versions.length < 2;
}

function openProjectDetailDialog(event) {
  activeProjectKey = event.currentTarget.dataset.projectKey || '';
  projectDetailTitle.textContent = event.currentTarget.dataset.projectTitle || 'Project Name Here here';
  updateProjectVersionOptions(activeProjectKey);
  updateProjectDetailCopy(activeProjectKey);
  setProjectDetailPanel('overview');
  showProjectDetailPage();
}

function closeProjectDetailDialog() {
  showProjectListPage();
}

navItems.forEach((item) => {
  item.addEventListener('click', (event) => {
    event.preventDefault();
    activateTab(item.dataset.tab);
  });

  item.addEventListener('focus', updateGlowColors);
});

tabTriggers.forEach((trigger) => {
  trigger.addEventListener('click', (event) => {
    event.preventDefault();
    activateTab(trigger.dataset.tabTrigger);
  });
});

skillRowShells.forEach((shell) => {
  const row = shell.querySelector('.skill-card-row');

  shell.querySelectorAll('[data-skill-scroll]').forEach((button) => {
    button.addEventListener('click', () => {
      const direction = button.dataset.skillScroll === 'next' ? 1 : -1;
      row.scrollBy({
        left: direction * Math.max(row.clientWidth * 0.75, 220),
        behavior: 'smooth',
      });
    });
  });

  row.addEventListener('scroll', updateSkillRowControls, { passive: true });
});

window.addEventListener('resize', updateSkillRowControls);
window.addEventListener('wheel', routeWheelToActivePanel, { passive: false });
updateSkillRowControls();

certificateDialogOpeners.forEach((button) => {
  button.addEventListener('click', openCertificateDialog);
});

certificateDialogClosers.forEach((button) => {
  button.addEventListener('click', closeCertificateDialog);
});

certificationSegmentButtons.forEach((button) => {
  button.addEventListener('click', () => {
    certificationSegmentButtons.forEach((segmentButton) => {
      const isActive = segmentButton === button;
      segmentButton.classList.toggle('active', isActive);
      segmentButton.setAttribute('aria-selected', String(isActive));
    });
    certificationViews.forEach((view) => {
      view.hidden = view.dataset.certificationView !== button.dataset.certificationViewTrigger;
    });
  });
});

projectImageOpeners.forEach((button) => {
  button.addEventListener('click', openProjectImageDialog);
});

projectImageClosers.forEach((button) => {
  button.addEventListener('click', closeProjectImageDialog);
});

projectDetailOpeners.forEach((button) => {
  button.addEventListener('click', openProjectDetailDialog);
});

projectDetailClosers.forEach((button) => {
  button.addEventListener('click', closeProjectDetailDialog);
});

projectDetailTabs.forEach((button) => {
  button.addEventListener('click', () => {
    setProjectDetailPanel(button.dataset.projectDetailTab);
  });
});

projectVersionSelect.addEventListener('change', () => {
  updateProjectDetailCopy(activeProjectKey);
  setProjectDetailPanel('architecture');
});

window.addEventListener('keydown', (event) => {
  if (event.key === 'Escape' && !certificateDialog.hidden) {
    closeCertificateDialog();
  }
  if (event.key === 'Escape' && !projectImageDialog.hidden) {
    closeProjectImageDialog();
  }
  if (event.key === 'Escape' && !projectDetailPage.hidden) {
    closeProjectDetailDialog();
  }
});
