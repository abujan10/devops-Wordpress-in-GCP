provider "google" {
 credentials = file("wp.json")
 project     = var.project
}

#VPC_CREATION

resource "google_compute_network" "wordpressvpc" {

  name = "wordpressvpc"
  project = var.project
  routing_mode = "GLOBAL"
  auto_create_subnetworks = false

}

#SUBNET_CREATION

resource "google_compute_subnetwork" "subnetworkword" {

  name          = "subnet1"
  ip_cidr_range = "10.10.12.0/24"
  region        = "us-west1"
  network       = "${google_compute_network.wordpressvpc.name}"
  project    = var.project
}


#FIREWALL_CREATION

resource "google_compute_firewall" "firewall" {
  name    = "firewall"
  network = "${google_compute_network.wordpressvpc.name}"
  project = var.project


  allow {
    protocol = "icmp"
  }


  allow {
    protocol = "tcp"
    ports    = ["80", "3306", "22"]
  }


  source_tags = ["web"]
  source_ranges = ["0.0.0.0/0"]
}

#INSTANCECREATION

resource "google_compute_instance" "wordpressinst" {

  name         = "wordpress"
  machine_type = "n1-standard-1"
  zone         = "us-west1-c"
  project = var.project


 
  boot_disk {

    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  network_interface {

    network = "${google_compute_network.wordpressvpc.name}"
    subnetwork = "${google_compute_subnetwork.subnetworkword.name}"
    subnetwork_project = "devops-19716"
    access_config {
    
    }
    
  }

 metadata_startup_script = file("wordpress.sh")
}



#DB_INSTANCE_CREATION 


resource "google_sql_database_instance" "instance" {

  name   = "wordpressdbinstance"
  database_version = "MYSQL_5_6"
  region = "us-central1"
  project = "devops-19716"
  settings {

    tier = "db-f1-micro"
    ip_configuration {

      ipv4_enabled = true
      authorized_networks {

        name = "public  network"
        value = "0.0.0.0/0"
      }
    }
  }
}

#DATABASE_CREATION

resource "google_sql_database" "database" {

  name     = "wordpress"
  instance = google_sql_database_instance.instance.name
  project = "devops-19716"
}



#DB_USER_CREATION

resource "google_sql_user" "users" {

  name     = var.dbuser
  instance = google_sql_database_instance.instance.name
  project =  "devops-19716"
  password = var.dbpass
}

output "wordpressip" {

            value = google_compute_instance.wordpressinst.network_interface.0.network_ip
  }


