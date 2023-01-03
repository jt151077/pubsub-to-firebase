#
# Copyright 2021 Google LLC
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

import json
import math
import os
import base64
import random
import functions_framework

from google.cloud import firestore

PROJECT_ID = os.getenv("PROJECT_ID", "")

client = firestore.Client(project=PROJECT_ID)

def crusher(data, context):
    val = math.nan;
    payload = base64.b64decode(data['data']).decode('utf-8');
    jsonPayload = json.loads(payload);
    
    if jsonPayload['status'] == 'running':
        print('running');
        val = jsonPayload['value'];
    else:
        print('reset');
    
    doc_ref = client.collection('crusher').document("status")
    if math.isnan(val):
        doc_ref.set({'value': 0, 'pant': 1000000})
    else:
        newpant = random.randint(10000, 20000)
        doc_ref.update({'value': firestore.Increment(val), 'pant': firestore.Increment(newpant)})

    return "ok"

if __name__ == '__crusher__':
    crusher('data', 'context')