import hilog from '@ohos.hilog';

const TAG = 'ZooFramework';
const DOMAIN = 0xFF00;

export class ZooLogger {
  static debug(message: string, ...args: any[]) {
    hilog.debug(DOMAIN, TAG, message, args);
  }

  static info(message: string, ...args: any[]) {
    hilog.info(DOMAIN, TAG, message, args);
  }

  static warn(message: string, ...args: any[]) {
    hilog.warn(DOMAIN, TAG, message, args);
  }

  static error(message: string, ...args: any[]) {
    hilog.error(DOMAIN, TAG, message, args);
  }
}
