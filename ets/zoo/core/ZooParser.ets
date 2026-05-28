import { ZooLogger } from '../common/ZooLogger';
import { ZooTemplate } from './ZooTemplate';

export class ZooParser {
  private static readonly FOR_PATTERN = /^\s*\{\{\s*(\w+)\s+in\s+(\w+)\s*\}\}\s*$/;
  private static readonly BINDING_PATTERN = /^\{\{([^}]+)\}\}/;
  private static readonly STRING_LITERAL_PATTERN = /^`([^`]*)`$/;

  static parse(jsonStr: string): ZooTemplate {
    try {
      const json = JSON.parse(jsonStr);
      return this.parseTemplate(json);
    } catch (e) {
      ZooLogger.error('ZooParser: Failed to parse JSON template: %{public}s', e.message);
      throw new Error('Invalid JSON template');
    }
  }

  static parseTemplate(json: any): ZooTemplate {
    if (!json.type) {
      ZooLogger.error('ZooParser: Template node missing required "type" field');
      throw new Error('Template node missing required "type" field');
    }

    const template: ZooTemplate = {
      type: json.type
    };

    if (json.id !== undefined) {
      template.id = json.id;
    }

    if (json.class !== undefined) {
      template.class = json.class;
    }

    if (json.style !== undefined) {
      template.style = json.style;
    }

    if (json.data !== undefined) {
      template.data = json.data;
    }

    if (json.event !== undefined) {
      template.event = json.event;
    }

    if (json.for !== undefined) {
      template.for = json.for;
    }

    if (Array.isArray(json.children)) {
      template.children = json.children.map((child: any) => this.parseTemplate(child));
    }

    return template;
  }

  static parseForExpression(forExpr: string): { itemName: string; listName: string } | null {
    const match = forExpr.match(this.FOR_PATTERN);
    if (match) {
      return {
        itemName: match[1],
        listName: match[2]
      };
    }
    return null;
  }

  static extractBindingExpressions(text: string): string[] {
    const expressions: string[] = [];
    const regex = /\{\{([^}]+)\}\}/g;
    let match;
    while ((match = regex.exec(text)) !== null) {
      expressions.push(match[1].trim());
    }
    return expressions;
  }

  static extractStringLiteral(text: string): string | null {
    const match = text.match(this.STRING_LITERAL_PATTERN);
    if (match) {
      return match[1];
    }
    return null;
  }

  static isBindingExpression(text: string): boolean {
    return this.BINDING_PATTERN.test(text);
  }

  static isStringLiteral(text: string): boolean {
    return this.STRING_LITERAL_PATTERN.test(text);
  }
}
