import { type ToolDefinition } from "@opencode-ai/plugin";
declare const plugin: () => Promise<{
    tool: {
        [key: string]: ToolDefinition;
    };
}>;
export default plugin;
