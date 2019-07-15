# Configure Slack Notifications for TFE
[ref](https://www.terraform.io/docs/enterprise/workspaces/notifications.html#slack)

## Slack Setup

- create Slack app to support [TFE webhook](https://api.slack.com/incoming-webhooks#create_a_webhook)
- provide app name
- enable incoming webhooks
- save

### Incoming Webhook

- active incoming webhook slider from _off_ to _on_
- depending on org policy and your rights, you may need to request to add new webhook (must be authorized by Slack site admins)

## Once authorized...

_marry Slack app you created to Slack org and channel_

- create channel as destination for notifications
- click add new webhook to workspace
- select channel name from drop-down and click agree

## TFE Setup

_notifications are configured per workspace_

- select a workspace
- settings > notifications

- select Slack
- provide name
- provide Slack webhook URL (from Slack "Incoming Webhooks" page in previous step)
- select triggers
- select create a notification
	- you should immediately receive a status 200 and green check if the connection was successful

- a test message will be sent to your channel _Verification of <your TFE notification name>_

