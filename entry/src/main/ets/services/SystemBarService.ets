/**
 * 系统状态栏颜色管理服务
 * 注意：当前版本仅保留空壳以避免编译错误。
 * HarmonyOS API 对 getLastWindow/getMainWindow 返回 Promise，
 * 若需动态切换系统状态栏颜色，可在 Ability 层使用 window API。
 */
export class SystemBarService {
  private static instance: SystemBarService | null = null
  private constructor() {}

  public static getInstance(): SystemBarService {
    if (!SystemBarService.instance) {
      SystemBarService.instance = new SystemBarService()
    }
    return SystemBarService.instance
  }

  public setDarkStatusBar(): void {}
  public setLightStatusBar(): void {}
  public setCustomStatusBar(
    _statusBarColor: string,
    _statusBarContentColor: string,
    _navigationBarColor: string,
    _navigationBarContentColor: string
  ): void {}
}
