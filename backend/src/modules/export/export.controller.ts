import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ExportService } from './export.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('export')
@Controller('export')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ExportController {
  constructor(private readonly exportService: ExportService) {}

  @Post('geojson')
  @ApiOperation({ summary: 'Export data to GeoJSON format' })
  async exportGeoJSON(@Body() data: any) {
    return this.exportService.exportToGeoJSON(data);
  }

  @Post('kml')
  @ApiOperation({ summary: 'Export data to KML format' })
  async exportKML(@Body() data: any) {
    return this.exportService.exportToKML(data);
  }

  @Post('gpx')
  @ApiOperation({ summary: 'Export data to GPX format' })
  async exportGPX(@Body() data: any) {
    return this.exportService.exportToGPX(data);
  }

  @Post('pdf')
  @ApiOperation({ summary: 'Export data to PDF with map' })
  async exportPDF(@Body() data: any) {
    return this.exportService.exportToPDF(data);
  }
}
