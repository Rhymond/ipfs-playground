package deployer

import (
	"context"
	"fmt"

	"github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/container"
	"github.com/docker/docker/client"
)

type Deployer struct {
	containerID string
}

func New() *Deployer {
	return &Deployer{}
}

func (d *Deployer) Start(ctx context.Context) error {
	if d.containerID != "" {
		return fmt.Errorf("container %s is already running", d.containerID)
	}

	cli, err := client.NewClientWithOpts(client.FromEnv, client.WithAPIVersionNegotiation())
	if err != nil {
		return fmt.Errorf("unable to get docker client: %w", err)
	}

	_, err = cli.ImagePull(ctx, "ipfs/go-ipfs", types.ImagePullOptions{})
	if err != nil {
		return fmt.Errorf("unable to pull the image: %w", err)
	}

	resp, err := cli.ContainerCreate(ctx, &container.Config{
		Image: "ipfs/go-ipfs",
	}, nil, nil, nil, "")
	if err != nil {
		return fmt.Errorf("unable to create container: %w", err)
	}

	if err := cli.ContainerStart(ctx, resp.ID, types.ContainerStartOptions{}); err != nil {
		panic(err)
	}

	statusCh, errCh := cli.ContainerWait(ctx, resp.ID, container.WaitConditionNotRunning)
	select {
	case err := <-errCh:
		if err != nil {
			return err
		}
	case <-statusCh:
	}

	d.containerID = resp.ID
	return nil
}

func (d *Deployer) Logs(ctx context.Context) ([]byte, error) {
	cli, err := client.NewClientWithOpts(client.FromEnv, client.WithAPIVersionNegotiation())
	if err != nil {
		return nil, fmt.Errorf("unable to get docker client: %w", err)
	}

	out, err := cli.ContainerLogs(ctx, d.containerID, types.ContainerLogsOptions{ShowStdout: true, ShowStderr: true})
	if err != nil {
		return nil, fmt.Errorf("unable to get container logs: %w", err)
	}

	var b []byte
	if _, err = out.Read(b); err != nil {
		return nil, fmt.Errorf("failed to read from log reader: %w", err)
	}

	return b, nil
}
