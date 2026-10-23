import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { ParcelsService } from './parcels.service';
import { CreateParcelDto } from './dto/create-parcel.dto';
import { UpdateParcelDto } from './dto/update-parcel.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('parcels')
@Controller('parcels')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ParcelsController {
  constructor(private readonly parcelsService: ParcelsService) {}

  @Post()
  @ApiOperation({ summary: 'Create new land parcel measurement' })
  @ApiResponse({ status: 201, description: 'Parcel created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid data' })
  create(
    @CurrentUser('id') userId: string,
    @Body() createParcelDto: CreateParcelDto,
  ) {
    return this.parcelsService.create(userId, createParcelDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all user parcels' })
  @ApiResponse({ status: 200, description: 'List of parcels' })
  findAll(@CurrentUser('id') userId: string) {
    return this.parcelsService.findAll(userId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get parcel by ID' })
  @ApiResponse({ status: 200, description: 'Parcel found' })
  @ApiResponse({ status: 404, description: 'Parcel not found' })
  findOne(@Param('id') id: string, @CurrentUser('id') userId: string) {
    return this.parcelsService.findOne(id, userId);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update parcel' })
  @ApiResponse({ status: 200, description: 'Parcel updated' })
  @ApiResponse({ status: 404, description: 'Parcel not found' })
  update(
    @Param('id') id: string,
    @CurrentUser('id') userId: string,
    @Body() updateParcelDto: UpdateParcelDto,
  ) {
    return this.parcelsService.update(id, userId, updateParcelDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete parcel' })
  @ApiResponse({ status: 200, description: 'Parcel deleted' })
  @ApiResponse({ status: 404, description: 'Parcel not found' })
  remove(@Param('id') id: string, @CurrentUser('id') userId: string) {
    return this.parcelsService.remove(id, userId);
  }

  @Post(':id/favorite')
  @ApiOperation({ summary: 'Toggle parcel favorite status' })
  @ApiResponse({ status: 200, description: 'Favorite status toggled' })
  toggleFavorite(@Param('id') id: string, @CurrentUser('id') userId: string) {
    return this.parcelsService.toggleFavorite(id, userId);
  }
}
