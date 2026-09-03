<?php

declare(strict_types=1);

namespace App\Commands\Env\Init;

use App\Commands\Base;
use Illuminate\Contracts\Container\BindingResolutionException;

/**
 * @author      Andreas Knollmann
 * @copyright   2014-2026 Softwareentwicklung Andreas Knollmann
 * @license     http://www.opensource.org/licenses/mit-license.php MIT
 */
class Database extends Base
{
    protected function getCommandName(): string
    {
        return 'env:init:database';
    }

    protected function getCommandDescription(): string
    {
        return 'Initialize a database environment';
    }

    protected function getCommandParameters(): array
    {
        return [
            $this->prepareInputOption('serverName', 'Name of server to initialize the database on'),
            $this->prepareDefaultInputOption('host', 'localhost', 'Host of database server'),
            $this->prepareInputOption('id', 'Id of database, default: [serverName]_database'),
            $this->prepareInputOption('type', 'Type of database'),
            $this->prepareInputOption('dbVersion', 'Version of database'),
            $this->prepareDefaultInputOption('port', 3306, 'Port of database'),
            $this->prepareInputOption('user', 'User of database'),
            $this->prepareInputOption('password', 'Password of database'),
            $this->prepareInputOption('name', 'Name of database'),
        ];
    }

    /**
     * @throws BindingResolutionException
     */
    protected function executeCommand(): int
    {
        $serverName = $this->getOption('serverName');
        $host = $this->getOption('host');
        $id = $this->getOption('id');
        $type = $this->getRequiredOption('type', 'No database type specified!');
        $version = $this->getRequiredOption('dbVersion', 'No database version specified!');
        $port = $this->getOption('port');
        $user = $this->getRequiredOption('user', 'No database user specified!');
        $password = $this->getRequiredOption('password', 'No database password specified!');
        $name = $this->getRequiredOption('name', 'No database name specified!');

        $process = $this->app->make(\App\Models\Process\Env\Init\Database::class);

        $process->execute(
            $serverName,
            $host,
            $id,
            $type,
            $version,
            $port,
            $user,
            $password,
            $name,
        );

        return self::SUCCESS;
    }
}
