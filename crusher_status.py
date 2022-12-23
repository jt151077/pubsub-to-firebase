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
import random

from google.cloud import pubsub_v1

publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path("<PROJECT_ID>", "crusher-topic")

status = [
    "running",
    "reset"
]

item = {
    "status": status[0],
    "value": random.randrange(5, 20, 3)
}

# Data must be a bytestring
data = json.dumps(item)

# When you publish a message, the client returns a future.
future = publisher.publish(topic_path, data.encode("utf-8"))
print(future.result())