package testimpl

import (
	"context"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/scheduler"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	t.Run("VerifyTerraformOutputs", func(t *testing.T) {
		opts := ctx.TerratestTerraformOptions()
		id := terraform.Output(t, opts, "id")
		arn := terraform.Output(t, opts, "arn")
		name := terraform.Output(t, opts, "name")
		groupName := terraform.Output(t, opts, "group_name")

		require.NotEmpty(t, id, "id output must be set")
		require.NotEmpty(t, arn, "arn output must be set")
		require.NotEmpty(t, name, "name output must be set")
		assert.Equal(t, "default", groupName, "group_name should be default in complete example")
		assert.Equal(t, groupName+"/"+name, id, "id must be group_name/name format for scheduler schedule")
	})

	t.Run("VerifyScheduleViaAWSAPI", func(t *testing.T) {
		opts := ctx.TerratestTerraformOptions()
		scheduleName := terraform.Output(t, opts, "name")
		groupName := terraform.Output(t, opts, "group_name")
		region := terraform.Output(t, opts, "region")

		cfg, err := config.LoadDefaultConfig(context.Background(), config.WithRegion(region))
		require.NoError(t, err)

		client := scheduler.NewFromConfig(cfg)
		out, err := client.GetSchedule(context.Background(), &scheduler.GetScheduleInput{
			Name:      aws.String(scheduleName),
			GroupName: aws.String(groupName),
		})
		require.NoError(t, err)
		require.NotNil(t, out)

		assert.Equal(t, "ENABLED", string(out.State), "Schedule state must be ENABLED")
		assert.Equal(t, "OFF", string(out.FlexibleTimeWindow.Mode), "Flexible time window mode must be OFF")
		assert.Equal(t, "rate(1 minute)", *out.ScheduleExpression, "Schedule expression must match")
	})

	t.Run("VerifyScheduleSendsToSQS", func(t *testing.T) {
		opts := ctx.TerratestTerraformOptions()
		queueURL := terraform.Output(t, opts, "queue_url")
		region := terraform.Output(t, opts, "region")
		require.NotEmpty(t, queueURL, "queue_url output must be set")

		cfg, err := config.LoadDefaultConfig(context.Background(), config.WithRegion(region))
		require.NoError(t, err)

		sqsClient := sqs.NewFromConfig(cfg)

		// Wait up to 4 minutes for the schedule to fire and deliver a message.
		// Scheduler execution can be delayed by eventual consistency.
		var receivedCount int
		for i := 0; i < 48; i++ {
			time.Sleep(5 * time.Second)
			result, err := sqsClient.ReceiveMessage(context.Background(), &sqs.ReceiveMessageInput{
				QueueUrl:            aws.String(queueURL),
				MaxNumberOfMessages: 5,
				WaitTimeSeconds:     5,
			})
			require.NoError(t, err)
			if len(result.Messages) > 0 {
				receivedCount += len(result.Messages)
				break
			}
		}
		require.Greater(t, receivedCount, 0, "Schedule must have delivered at least one message to SQS")
	})
}

func TestComposableCompleteReadonly(t *testing.T, ctx types.TestContext) {
	t.Run("VerifyTerraformOutputs", func(t *testing.T) {
		opts := ctx.TerratestTerraformOptions()
		id := terraform.Output(t, opts, "id")
		arn := terraform.Output(t, opts, "arn")
		name := terraform.Output(t, opts, "name")
		groupName := terraform.Output(t, opts, "group_name")

		require.NotEmpty(t, id, "id output must be set")
		require.NotEmpty(t, name, "name output must be set")
		assert.Equal(t, "default", groupName, "group_name should be default in complete example")
		assert.Equal(t, groupName+"/"+name, id, "id must be group_name/name format for scheduler schedule")
		assert.Contains(t, arn, "scheduler", "arn must contain scheduler")
	})

	t.Run("VerifyScheduleViaAWSAPI", func(t *testing.T) {
		opts := ctx.TerratestTerraformOptions()
		scheduleName := terraform.Output(t, opts, "name")
		groupName := terraform.Output(t, opts, "group_name")
		region := terraform.Output(t, opts, "region")

		cfg, err := config.LoadDefaultConfig(context.Background(), config.WithRegion(region))
		require.NoError(t, err)

		client := scheduler.NewFromConfig(cfg)
		out, err := client.GetSchedule(context.Background(), &scheduler.GetScheduleInput{
			Name:      aws.String(scheduleName),
			GroupName: aws.String(groupName),
		})
		require.NoError(t, err)
		require.NotNil(t, out)

		assert.Equal(t, "ENABLED", string(out.State), "Schedule state must be ENABLED")
		assert.Equal(t, "OFF", string(out.FlexibleTimeWindow.Mode), "Flexible time window mode must be OFF")
	})
}
