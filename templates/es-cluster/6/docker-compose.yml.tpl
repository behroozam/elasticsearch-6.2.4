version: '2'
services:
    es-master:
        labels:
            io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
            io.rancher.container.hostname_override: container_name
            io.rancher.sidekicks: es-master-storage{{- if eq .Values.UPDATE_SYSCTL "true" -}},es-master-sysctl{{- end}}
        image: behroozam/elastic:6.2.3
        command:
        - sh
        - -c
        - 'chmod -R a+rwx /usr/share/elasticsearch/data'
        environment:
            - "cluster.name=${cluster_name}"
            - "node.name=$${HOSTNAME}"
            - "bootstrap.memory_lock=true"
            - "xpack.security.enabled=false"
            - "ES_JAVA_OPTS=-Xms${master_heap_size} -Xmx${master_heap_size}"
            - "discovery.zen.ping.unicast.hosts=es-master"
            - "discovery.zen.minimum_master_nodes=${minimum_master_nodes}"
            - "node.master=true"
            - "node.data=false"
        ulimits:
            memlock:
                soft: -1
                hard: -1
            nofile:
                soft: 65536
                hard: 65536
        mem_limit: ${master_mem_limit}
        mem_swappiness: 0
        cap_add:
            - IPC_LOCK
        volumes:
            - es-master-volume:/usr/share/elasticsearch/data
        volumes:
            es-master-volume:
                driver: local
    es-data:
        labels:
            io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
            io.rancher.container.hostname_override: container_name
            io.rancher.sidekicks: es-data-storage{{- if eq .Values.UPDATE_SYSCTL "true" -}},es-data-sysctl{{- end}}
        image: behroozam/elastic:6.2.3
        command:
        - sh
        - -c
        - 'chmod -R a+rwx /usr/share/elasticsearch/data'
        environment:
            - "cluster.name=${cluster_name}"
            - "node.name=$${HOSTNAME}"
            - "bootstrap.memory_lock=true"
            - "xpack.security.enabled=false"
            - "discovery.zen.ping.unicast.hosts=es-master"
            - "ES_JAVA_OPTS=-Xms${data_heap_size} -Xmx${data_heap_size}"
            - "node.master=false"
            - "node.data=true"
        ulimits:
            memlock:
                soft: -1
                hard: -1
            nofile:
                soft: 65536
                hard: 65536
        mem_limit: ${data_mem_limit}
        mem_swappiness: 0
        cap_add:
            - IPC_LOCK
        volumes:
            - es-data-volume:/usr/share/elasticsearch/data
        volumes:
            es-data-volumee:
                driver: local
        depends_on:
            - es-master

    es-client:
        labels:
            io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
            io.rancher.container.hostname_override: container_name
            io.rancher.sidekicks: es-client-storage{{- if eq .Values.UPDATE_SYSCTL "true" -}},es-client-sysctl{{- end}}
        image: behroozam/elastic:6.2.3
        command:
        - sh
        - -c
        - 'chmod -R a+rwx /usr/share/elasticsearch/data'
        environment:
            - "cluster.name=${cluster_name}"
            - "node.name=$${HOSTNAME}"
            - "bootstrap.memory_lock=true"
            - "xpack.security.enabled=false"
            - "discovery.zen.ping.unicast.hosts=es-master"
            - "ES_JAVA_OPTS=-Xms${client_heap_size} -Xmx${client_heap_size}"
            - "node.master=false"
            - "node.data=false"
        ulimits:
            memlock:
                soft: -1
                hard: -1
            nofile:
                soft: 65536
                hard: 65536
        mem_limit: ${client_mem_limit}
        mem_swappiness: 0
        cap_add:
            - IPC_LOCK
        volumes:
            - es-client-volume:/usr/share/elasticsearch/data
        volumes:
            es-client-volume:
                driver: local
        depends_on:
            - es-master


    {{- if eq .Values.UPDATE_SYSCTL "true" }}
    es-master-sysctl:
        labels:
            io.rancher.container.start_once: true
        network_mode: none
        image: rawmind/alpine-sysctl:0.1
        privileged: true
        environment:
            - "SYSCTL_KEY=vm.max_map_count"
            - "SYSCTL_VALUE=262144"
    es-data-sysctl:
        labels:
            io.rancher.container.start_once: true
        network_mode: none
        image: rawmind/alpine-sysctl:0.1
        privileged: true
        environment:
            - "SYSCTL_KEY=vm.max_map_count"
            - "SYSCTL_VALUE=262144"
    es-client-sysctl:
        labels:
            io.rancher.container.start_once: true
        network_mode: none
        image: rawmind/alpine-sysctl:0.1
        privileged: true
        environment:
            - "SYSCTL_KEY=vm.max_map_count"
            - "SYSCTL_VALUE=262144"
    {{- end}}
    