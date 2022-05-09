package main

import (
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

func main() {
	pulumi.Run(func(ctx *pulumi.Context) error {
		/*_, err := gitlab.NewLabel(ctx, "fixme", &gitlab.LabelArgs{
			Project:     pulumi.String("example"),
			Description: pulumi.String("issue with failing tests"),
			Color:       pulumi.String("#ffcc00"),
		})
		if err != nil {
			return err
		}*/
		return nil
	})
}
