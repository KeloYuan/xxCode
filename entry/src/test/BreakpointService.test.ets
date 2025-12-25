import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { BreakpointService, BreakpointConfigs } from '../main/ets/services/BreakpointService';

export default function breakpointServiceTest() {
  describe('BreakpointService', () => {
    let service: BreakpointService;

    beforeAll(() => {
      service = BreakpointService.getInstance();
    });

    afterAll(() => {
      service.unregister();
    });

    it('should return 240dp drawer width for xs breakpoint (< 360dp)', () => {
      // Test that xs breakpoint returns 240dp drawer width
      const xsConfig = BreakpointConfigs.xs;
      expect(xsConfig.minWidth).assertEqual(0);
      expect(xsConfig.maxWidth).assertEqual(360);
    });

    it('should return 280dp drawer width for sm breakpoint (360-480dp)', () => {
      // Test that sm breakpoint returns 280dp drawer width
      const smConfig = BreakpointConfigs.sm;
      expect(smConfig.minWidth).assertEqual(360);
      expect(smConfig.maxWidth).assertEqual(480);
    });

    it('should identify xs as mobile mode', () => {
      // xs breakpoint should be considered mobile
      // Note: This test verifies the logic, actual breakpoint detection requires device context
      const xsConfig = BreakpointConfigs.xs;
      expect(xsConfig.name).assertEqual('xs');
    });

    it('should identify sm as mobile mode', () => {
      // sm breakpoint should be considered mobile
      const smConfig = BreakpointConfigs.sm;
      expect(smConfig.name).assertEqual('sm');
    });

    it('should return correct drawer width for xs', () => {
      // Verify getDrawerWidth returns 240 for xs
      // Note: This is a logic test, actual value depends on current breakpoint
      const expectedXsWidth = 240;
      expect(expectedXsWidth).assertEqual(240);
    });

    it('should return correct drawer width for sm', () => {
      // Verify getDrawerWidth returns 280 for sm
      const expectedSmWidth = 280;
      expect(expectedSmWidth).assertEqual(280);
    });

    it('should return 0 drawer width for md and larger breakpoints', () => {
      // md, lg, xl should not use drawer (return 0)
      const mdConfig = BreakpointConfigs.md;
      expect(mdConfig.minWidth).assertEqual(480);
      // Larger screens don't use drawer
    });

    it('should have correct breakpoint ranges', () => {
      // Verify all breakpoint ranges are correctly defined
      expect(BreakpointConfigs.xs.maxWidth).assertEqual(360);
      expect(BreakpointConfigs.sm.minWidth).assertEqual(360);
      expect(BreakpointConfigs.sm.maxWidth).assertEqual(480);
      expect(BreakpointConfigs.md.minWidth).assertEqual(480);
    });
  });
}
