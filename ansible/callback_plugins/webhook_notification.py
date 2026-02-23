# -*- coding: utf-8 -*-

"""
Ansible callback plugin to send webhook notifications on playbook completion.
Sends summary on success, full details on failure.
"""

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import json
import os
from datetime import datetime
from ansible.plugins.callback import CallbackBase

try:
    import requests
    HAS_REQUESTS = True
except ImportError:
    HAS_REQUESTS = False


DOCUMENTATION = '''
    callback: webhook_notification
    type: notification
    short_description: Send webhook notifications on playbook completion
    description:
        - This callback sends webhook notifications when a playbook completes
        - On success, sends playbook name and summary
        - On failure, sends full error stack trace
    requirements:
        - requests (pip install requests)
    options:
        webhook_url:
            description: Webhook URL to send notifications to
            env:
                - name: ANSIBLE_WEBHOOK_URL
            ini:
                - section: callback_webhook_notification
                  key: webhook_url
            required: True
'''


class CallbackModule(CallbackBase):
    """
    Callback plugin to send webhook notifications
    """
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'notification'
    CALLBACK_NAME = 'webhook_notification'
    CALLBACK_NEEDS_WHITELIST = True

    def __init__(self):
        super(CallbackModule, self).__init__()
        self.playbook_name = None
        self.start_time = None
        self.errors = []
        self.failed_tasks = []
        self.stats = {}

    def v2_playbook_on_start(self, playbook):
        """Capture playbook start"""
        self.playbook_name = os.path.basename(playbook._file_name)
        self.start_time = datetime.now()

    def v2_runner_on_failed(self, result, ignore_errors=False):
        """Capture failed tasks"""
        if not ignore_errors:
            task_name = result._task.get_name()
            host = result._host.get_name()

            error_detail = {
                'host': host,
                'task': task_name,
                'message': result._result.get('msg', ''),
                'result': result._result
            }

            self.failed_tasks.append(error_detail)

    def v2_runner_on_unreachable(self, result):
        """Capture unreachable hosts"""
        host = result._host.get_name()
        error_detail = {
            'host': host,
            'task': 'Connection',
            'message': 'Host unreachable',
            'result': result._result
        }
        self.failed_tasks.append(error_detail)

    def v2_playbook_on_stats(self, stats):
        """Send notification when playbook completes"""
        if not HAS_REQUESTS:
            self._display.warning("requests library not found, skipping webhook notification")
            return

        # Get webhook URL from environment or ansible.cfg
        webhook_url = os.environ.get('ANSIBLE_WEBHOOK_URL')
        if not webhook_url:
            webhook_url = self.get_option('webhook_url')

        if not webhook_url:
            self._display.warning("No webhook URL configured, skipping notification")
            return

        # Calculate duration
        duration = (datetime.now() - self.start_time).total_seconds() if self.start_time else 0

        # Gather stats
        hosts = sorted(stats.processed.keys())
        summary = {
            'ok': 0,
            'changed': 0,
            'unreachable': 0,
            'failed': 0,
            'skipped': 0,
            'rescued': 0,
            'ignored': 0
        }

        for host in hosts:
            s = stats.summarize(host)
            summary['ok'] += s['ok']
            summary['changed'] += s['changed']
            summary['unreachable'] += s['unreachable']
            summary['failed'] += s['failures']
            summary['skipped'] += s['skipped']
            summary['rescued'] += s['rescued']
            summary['ignored'] += s['ignored']

        # Determine if playbook failed
        has_failures = summary['failed'] > 0 or summary['unreachable'] > 0
        status = 'failed' if has_failures else 'success'

        # Format duration
        duration_str = f"{int(duration // 60)}m {int(duration % 60)}s" if duration >= 60 else f"{int(duration)}s"

        # Build title
        if has_failures:
            title = f"❌ Playbook {self.playbook_name} FAILED"
        else:
            title = f"✅ Playbook {self.playbook_name} SUCCESS"

        # Build formatted message
        if has_failures:
            # Detailed message for failures
            message_lines = [
                f"Playbook: {self.playbook_name}",
                f"Status: FAILED",
                f"Duration: {duration_str}",
                f"",
                "📊 Summary:",
                f"  • OK: {summary['ok']}",
                f"  • Changed: {summary['changed']}",
                f"  • Failed: {summary['failed']}",
                f"  • Unreachable: {summary['unreachable']}",
                f"  • Skipped: {summary['skipped']}",
                f"",
                "🔥 Errors:"
            ]

            for idx, error in enumerate(self.failed_tasks, 1):
                message_lines.append(f"\n[Error {idx}]")
                message_lines.append(f"Host: {error['host']}")
                message_lines.append(f"Task: {error['task']}")
                message_lines.append(f"Message: {error['message']}")

                # Add detailed error information
                result = error['result']
                if 'stderr' in result and result['stderr']:
                    message_lines.append(f"STDERR:\n{result['stderr']}")
                if 'stdout' in result and result['stdout']:
                    message_lines.append(f"STDOUT:\n{result['stdout']}")
                if 'exception' in result:
                    message_lines.append(f"Exception:\n{result['exception']}")

            message = "\n".join(message_lines)
        else:
            # Concise message for success
            message_lines = [
                f"Playbook: {self.playbook_name}",
                f"Status: SUCCESS",
                f"Duration: {duration_str}",
                f"",
                "📊 Summary:",
                f"  • OK: {summary['ok']}",
                f"  • Changed: {summary['changed']}",
                f"  • Skipped: {summary['skipped']}",
                f"",
                f"Hosts: {', '.join(hosts)}"
            ]
            message = "\n".join(message_lines)

        # Build notification payload
        payload = {
            'text': f"*{title}*\n\n{message}"
        }

        # Send webhook
        try:
            response = requests.post(
                webhook_url,
                json=payload,
                headers={'Content-Type': 'application/json'},
                timeout=10
            )

            if response.status_code >= 200 and response.status_code < 300:
                self._display.display(f"Webhook notification sent successfully to {webhook_url}")
            else:
                self._display.warning(
                    f"Webhook notification failed with status {response.status_code}: {response.text}"
                )
        except Exception as e:
            self._display.warning(f"Failed to send webhook notification: {str(e)}")
