import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { ToolsService } from './tools.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('tools')
@Controller('tools')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ToolsController {
  constructor(private readonly toolsService: ToolsService) {}

  @Post('calculate-area')
  @ApiOperation({ summary: 'Calculate area from coordinates' })
  @ApiResponse({ status: 200, description: 'Area calculated' })
  calculateArea(@Body() data: { coordinates: number[][][] }) {
    return this.toolsService.calculateArea(data.coordinates);
  }

  @Post('calculate-distance')
  @ApiOperation({ summary: 'Calculate distance between two points' })
  @ApiResponse({ status: 200, description: 'Distance calculated' })
  calculateDistance(
    @Body()
    data: {
      from: { latitude: number; longitude: number };
      to: { latitude: number; longitude: number };
    },
  ) {
    return this.toolsService.calculateDistance(data.from, data.to);
  }

  @Post('convert-to-utm')
  @ApiOperation({ summary: 'Convert WGS84 to UTM' })
  @ApiResponse({ status: 200, description: 'Coordinates converted' })
  convertToUtm(@Body() data: { latitude: number; longitude: number }) {
    return this.toolsService.wgs84ToUtm(data.latitude, data.longitude);
  }

  @Post('convert-to-wgs84')
  @ApiOperation({ summary: 'Convert UTM to WGS84' })
  @ApiResponse({ status: 200, description: 'Coordinates converted' })
  convertToWgs84(@Body() data: { easting: number; northing: number }) {
    return this.toolsService.utmToWgs84(data.easting, data.northing);
  }

  @Post('decimal-to-dms')
  @ApiOperation({ summary: 'Convert decimal degrees to DMS' })
  @ApiResponse({ status: 200, description: 'Coordinates converted' })
  decimalToDms(@Body() data: { decimal: number; isLatitude: boolean }) {
    return this.toolsService.decimalToDms(data.decimal, data.isLatitude);
  }

  @Post('dms-to-decimal')
  @ApiOperation({ summary: 'Convert DMS to decimal degrees' })
  @ApiResponse({ status: 200, description: 'Coordinates converted' })
  dmsToDecimal(
    @Body()
    data: {
      degrees: number;
      minutes: number;
      seconds: number;
      direction: string;
    },
  ) {
    return this.toolsService.dmsToDecimal(
      data.degrees,
      data.minutes,
      data.seconds,
      data.direction,
    );
  }
}
