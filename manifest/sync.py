#!/usr/bin/env python

# Copyright 2023.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import logging
import typing

logging.basicConfig(level=logging.DEBUG)
LOGGER = logging.getLogger(__name__)


class Controller(BaseHTTPRequestHandler):
    def sync(self, parent: dict, related: dict) -> list:
        LOGGER.info(f'Processing: {parent}')
        owned_resources = []
        if len(related) == 0:
            LOGGER.info("No relasted resource has been detected, cleaning-up")
            return owned_resources
        for group in related:
            for obj in related[group]:
                LOGGER.info(f"Adopting resource {group} {obj}")
                owned_resources.append(self.new_adopted(**related[group][obj]))
        return owned_resources

    def new_adopted(self, kind: str, apiVersion: str, metadata: dict, *_, **__) -> dict:
        return {
            'apiVersion': apiVersion,
            'kind': kind,
            'metadata': metadata.copy(),
        }

    def update_status(self, children):
        ownedResources = [
            {
                'kind': child['kind'],
                'apiVersion': child['apiVersion'],
                'name': child['metadata'].get('name'),
                'namespace': child['metadata'].get('namespace'),
            } for child in children
        ]

        return {'ownedResources': ownedResources}

    def customize(self, controller, selector) -> list:
        return [
            {**c, 'labelSelector': selector} for c in controller
        ]

    def do_POST(self):
        if self.path == '/sync':
            observed: dict = json.loads(self.rfile.read(
                int(self.headers.get('content-length'))))
            parent: dict = observed['parent']
            related: dict = observed['related']
            LOGGER.info("/sync %s", parent['metadata']['name'])
            children: list = self.sync(parent, related)
            response: dict = {
                'children': children,
                'status': self.update_status(children),
            }
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(response).encode('utf-8'))
        elif self.path == '/customize':
            request: dict = json.loads(self.rfile.read(
                int(self.headers.get('content-length'))))
            parent: dict = request['parent']
            controller: dict = request['controller']
            LOGGER.info("/customize %s", parent['metadata']['name'])
            related_resources: dict = {
                'relatedResources': self.customize(
                    controller['spec'].get('childResources', []),
                    parent['spec'].get('selector', {}))
            }
            LOGGER.info("Related resources: \n %s", related_resources)
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(related_resources).encode('utf-8'))
        else:
            self.send_response(404)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            error_msg: dict = {
                'error': '404',
                'endpoint': self.path
            }
            self.wfile.write(json.dumps(error_msg).encode('utf-8'))


HTTPServer(('', 80), Controller).serve_forever()
