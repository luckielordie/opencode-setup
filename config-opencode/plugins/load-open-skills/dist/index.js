import { tool } from "@opencode-ai/plugin";
import * as fs from "fs";
import * as path from "path";
const OPEN_SKILLS_PATH = "/home/kytusdevenn/open-skills/skills";
const loadOpenSkillTool = tool({
    description: "Load and read a skill from open-skills directory",
    args: {
        skillName: tool.schema.string().describe("Name of the skill to load from open-skills"),
    },
    async execute(args, context) {
        const skillPath = path.join(OPEN_SKILLS_PATH, args.skillName, "SKILL.md");
        if (!fs.existsSync(skillPath)) {
            return `Skill "${args.skillName}" not found in open-skills. Available skills: ${fs.readdirSync(OPEN_SKILLS_PATH).filter(f => fs.statSync(path.join(OPEN_SKILLS_PATH, f)).isDirectory()).join(", ")}`;
        }
        const content = fs.readFileSync(skillPath, "utf-8");
        return content;
    },
});
const listOpenSkillsTool = tool({
    description: "List all available skills in open-skills directory",
    args: {},
    async execute(args, context) {
        if (!fs.existsSync(OPEN_SKILLS_PATH)) {
            return "open-skills directory not found";
        }
        const skills = fs.readdirSync(OPEN_SKILLS_PATH).filter(dir => {
            return fs.statSync(path.join(OPEN_SKILLS_PATH, dir)).isDirectory();
        });
        return `Available skills: ${skills.join(", ")}`;
    },
});
const plugin = async () => {
    return {
        tool: {
            "load-open-skill": loadOpenSkillTool,
            "list-open-skills": listOpenSkillsTool,
        },
    };
};
export default plugin;
